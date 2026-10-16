#!/usr/bin/env node
import {chromium} from '@playwright/test';
import fs from 'fs';
import os from 'os';
import path from 'path';
import {fileURLToPath} from 'url';

const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..');
const CONFIGS_DIR = path.join(REPO, 'affiliate/configs');
const API = 'https://api.wepublish.digital/api/graphql';
const BROWSER_UA =
	'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0 Safari/537.36';
const RENDER_TIMEOUT_MS = 35000;

// Loading every publication on production must not inflate retailer stats, send bot ad
// impressions or flood Sentry, so tracking, ad and monitoring hosts are always blocked.
const BLOCKED_HOSTS =
	/(^|\.)(stats\.publitas\.com|google-analytics\.com|googletagmanager\.com|doubleclick\.net|googlesyndication\.com|googleadservices\.com|adservice\.google\.[a-z.]+|posthog\.com|sentry\.io|facebook\.(com|net)|hotjar\.com|clarity\.ms|criteo\.(com|net)|amazon-adsystem\.com|adnxs\.com|rubiconproject\.com|pubmatic\.com|openx\.net|taboola\.com|outbrain\.com)$/;

const ORIGINS = {
	'folders-nl': 'https://folders.nl',
	'promobutler-be-nl': 'https://www.promobutler.be/nl',
	'promobutler-be-fr': 'https://www.promobutler.be/fr'
};

function parseArgs() {
	const args = {
		sites: null,
		out: path.join(os.tmpdir(), `publication-check-${new Date().toISOString().replace(/[:.]/g, '-')}`),
		concurrency: 8,
		limit: null,
		only: null,
		viewer: 'auto'
	};
	const argv = process.argv.slice(2);
	for (let i = 0; i < argv.length; i++) {
		const [key, inline] = argv[i].replace(/^--/, '').split('=');
		const value = inline ?? argv[++i];
		if (key === 'sites') {
			args.sites = value.split(',').map((s) => s.trim());
		} else if (key === 'out') {
			args.out = path.resolve(value);
		} else if (key === 'concurrency') {
			args.concurrency = Number(value);
		} else if (key === 'limit') {
			args.limit = Number(value);
		} else if (key === 'only') {
			args.only = new Set(value.split(',').map((s) => s.trim()));
		} else if (key === 'viewer') {
			args.viewer = value;
		} else {
			throw new Error(`Unknown option --${key}`);
		}
	}
	if (!['auto', 'sdk', 'wepublish'].includes(args.viewer)) {
		throw new Error('--viewer must be auto, sdk or wepublish');
	}
	return args;
}

function loadSites(filter) {
	const slugs = fs
		.readdirSync(CONFIGS_DIR)
		.filter((d) => ORIGINS[d] || /^promozilla-[a-z]{2}$/.test(d))
		.filter((d) => !filter || filter.some((f) => d === f || d.startsWith(`${f}-`)));
	return slugs.map((slug) => {
		const src = fs.readFileSync(path.join(CONFIGS_DIR, slug, `${slug}.config.ts`), 'utf8');
		const viewerPath = src.match(/ApplicationRoute\.PUBLICATION_VARIANT_VIEWER\]:\s*'([^']*)'/)?.[1];
		if (!viewerPath) {
			throw new Error(`No PUBLICATION_VARIANT_VIEWER route in ${slug}`);
		}
		const origin = ORIGINS[slug] ?? `https://promozilla.com/${slug.slice('promozilla-'.length)}`;
		return {
			slug,
			label: ORIGINS[slug] ? slug : slug.slice('promozilla-'.length).toUpperCase(),
			origin,
			cookieDomain: new URL(origin).hostname.replace(/^www\./, ''),
			viewerPath: viewerPath.replace('/:publicationVariantSlug/:pageNumber?', ''),
			dataSlug: src.match(/overrideDataSourceSlug:\s*'([^']+)'/)?.[1] ?? slug,
			publitasViewerDomain: src.match(/publitasViewerDomain:\s*'([^']+)'/)?.[1] ?? 'view.publitas.com',
			publitasAccountId: src.match(/publitasAccountId:\s*(\d+)/)?.[1] ?? null
		};
	});
}

function loadOverrideSlugs() {
	const src = fs.readFileSync(path.join(REPO, 'src/utils/feature-flag.utils.ts'), 'utf8');
	const block = src.match(/OVERRIDE_SLUGS[^=]*=\s*\[([\s\S]*?)\];/)?.[1] ?? '';
	return new Set([...block.matchAll(/'([^']+)'/g)].map((m) => m[1]));
}

async function gql(query, variables) {
	for (let attempt = 1; ; attempt++) {
		try {
			const res = await fetch(API, {
				method: 'POST',
				headers: {'content-type': 'application/json'},
				body: JSON.stringify({query, variables})
			});
			return await res.json();
		} catch (error) {
			if (attempt >= 3) {
				throw error;
			}
			await new Promise((r) => setTimeout(r, 1000 * attempt));
		}
	}
}

async function pool(items, concurrency, fn) {
	const results = new Array(items.length);
	let next = 0;
	async function worker() {
		while (next < items.length) {
			const index = next++;
			results[index] = await fn(items[index], index);
		}
	}
	await Promise.all(Array.from({length: Math.min(concurrency, items.length)}, worker));
	return results;
}

async function fetchFeatureFlags(site) {
	const body = await gql('query($s:String!){affiliateCmsAffiliate(affiliateSlug:$s){featureFlags}}', {
		s: site.slug
	});
	return body.data?.affiliateCmsAffiliate?.featureFlags ?? {};
}

async function fetchLivePublications(site) {
	const query = `query($options: InputAffiliateCmsPublicationVariantPagination!){affiliateCmsPublicationVariants(options:$options){items{slug name validFrom validUntil retailer{name}} meta{totalPages}}}`;
	const items = [];
	for (let page = 1; ; page++) {
		const body = await gql(query, {
			options: {affiliateSlug: site.dataSlug, excludeExpired: true, excludePlanned: true, limit: 100, page}
		});
		if (body.errors) {
			throw new Error(`${site.slug}: ${body.errors[0].message}`);
		}
		const data = body.data.affiliateCmsPublicationVariants;
		items.push(...data.items);
		if (page >= data.meta.totalPages) {
			return items;
		}
	}
}

async function fetchExpectedViewer(site, publication, overrideSlugs, overridesEnabled) {
	const body = await gql(
		`query($options: InputAffiliateCmsViewerOptions!){affiliateCmsViewer(options:$options){publitasSlug publitasGroupSlug publitasAccountId publicationVariant{isExpired isUnavailable}}}`,
		{options: {affiliateSlug: site.dataSlug, slug: publication.slug, excludeExpired: false}}
	);
	const viewer = body.data?.affiliateCmsViewer;
	if (body.errors || !viewer) {
		return {expected: 'api-error', reason: body.errors?.[0]?.message ?? 'no viewer data'};
	}
	const {publitasSlug, publitasGroupSlug, publitasAccountId, publicationVariant} = viewer;
	const readerUrl =
		publitasSlug && publitasGroupSlug
			? `https://${site.publitasViewerDomain}/${publitasGroupSlug}/${publitasSlug}/page/1`
			: null;
	if (publicationVariant.isUnavailable && !publicationVariant.isExpired) {
		return {expected: 'unavailable', readerUrl, reason: 'marked unavailable, users are redirected'};
	}
	if (!readerUrl) {
		return {expected: 'wepublish', reason: 'no Publitas slug'};
	}
	if (site.publitasAccountId && String(publitasAccountId) !== site.publitasAccountId) {
		return {expected: 'wepublish', readerUrl, reason: `Publitas account ${publitasAccountId}`};
	}
	if (publicationVariant.isExpired) {
		return {expected: 'wepublish', readerUrl, reason: 'expired'};
	}
	if (overridesEnabled && overrideSlugs.has(publication.slug)) {
		return {expected: 'wepublish', readerUrl, reason: 'on OVERRIDE_SLUGS'};
	}
	return {expected: 'sdk', readerUrl};
}

async function isBehindChallenge(origin) {
	try {
		const res = await fetch(origin, {headers: {'user-agent': BROWSER_UA}, redirect: 'follow'});
		return res.headers.get('cf-mitigated') === 'challenge';
	} catch {
		return false;
	}
}

async function checkReaderUrl(readerUrl) {
	for (let attempt = 1; ; attempt++) {
		try {
			const res = await fetch(readerUrl, {redirect: 'manual', headers: {'user-agent': BROWSER_UA}});
			return res.status;
		} catch (error) {
			if (attempt >= 2) {
				return `fetch failed: ${error.message}`;
			}
		}
	}
}

function isBlocked(url) {
	try {
		const u = new URL(url);
		return BLOCKED_HOSTS.test(u.hostname) || u.pathname === '/prebid-ads.js';
	} catch {
		return false;
	}
}

async function inspectPage(page, readerHost) {
	const main = await page.evaluate(() => {
		const canvas = document.querySelector('.canvas-viewer canvas.lower-canvas');
		let legacyPixels = null;
		if (canvas && canvas.width > 0) {
			try {
				const {data} = canvas.getContext('2d').getImageData(0, 0, canvas.width, canvas.height);
				let drawn = 0;
				for (let i = 0; i < data.length; i += 4 * 97) {
					if (data[i + 3] > 0 && (data[i] < 235 || data[i + 1] < 235 || data[i + 2] < 235)) {
						drawn++;
					}
				}
				legacyPixels = drawn;
			} catch {
				legacyPixels = -1;
			}
		}
		return {
			path: location.pathname,
			title: document.title,
			hasSdkContainer: !!document.querySelector('#publitas-sdk-container'),
			hasLegacyViewer: !!document.querySelector('.canvas-viewer'),
			legacyPixels
		};
	});
	const frame = page.frames().find((f) => readerHost.test(f.url()));
	let sdk = null;
	if (frame) {
		sdk = await frame
			.evaluate(() => ({
				visiblePageImages: [...document.querySelectorAll('img')].filter(
					(i) =>
						/\/pages\//.test(i.src) &&
						i.complete &&
						i.naturalWidth > 1 &&
						i.getBoundingClientRect().width > 50
				).length,
				text: (document.body?.innerText ?? '').trim().split('\n')[0].slice(0, 80)
			}))
			.catch((e) => ({visiblePageImages: 0, text: `frame error: ${e.message.slice(0, 80)}`}));
	}
	return {
		...main,
		sdk,
		sdkRendered: !!sdk && sdk.visiblePageImages > 0,
		legacyRendered: main.hasLegacyViewer && (main.legacyPixels > 50 || main.legacyPixels === -1),
		challenged: /just a moment/i.test(main.title)
	};
}

async function renderCheck(browser, site, publication, {bucket, readerHost, shotsDir}) {
	const ctx = await browser.newContext({viewport: {width: 1280, height: 900}, locale: 'en-US'});
	const url = `${site.origin}${site.viewerPath}/${publication.slug}`;
	let readerDocStatus = null;
	try {
		await ctx.route('**/*', (route) => {
			const req = route.request();
			if (isBlocked(req.url())) {
				return route.abort();
			}
			if (req.method() === 'POST' && /"query"\s*:\s*"\s*mutation/.test(req.postData() || '')) {
				return route.abort();
			}
			return route.continue();
		});
		if (bucket !== null) {
			await ctx.addCookies([
				{name: `reader-sdk-bucket-${site.slug}`, value: String(bucket), domain: site.cookieDomain, path: '/'}
			]);
		}
		ctx.on('response', (res) => {
			if (res.request().resourceType() === 'document' && readerHost.test(res.url())) {
				readerDocStatus = res.status();
			}
		});
		const page = await ctx.newPage();
		const started = Date.now();
		await page.goto(url, {waitUntil: 'domcontentloaded', timeout: 30000}).catch(() => {});
		let state = null;
		while (Date.now() - started < RENDER_TIMEOUT_MS) {
			await page.waitForTimeout(1000);
			state = await inspectPage(page, readerHost).catch(() => null);
			if (state && (state.sdkRendered || state.legacyRendered || state.challenged)) {
				break;
			}
		}
		await page.waitForTimeout(1000);
		state = (await inspectPage(page, readerHost).catch(() => null)) ?? state;
		const viewer = state?.sdkRendered ? 'sdk' : state?.legacyRendered ? 'wepublish' : 'none';
		const result = {url, viewer, ok: viewer !== 'none', readerDocStatus, state, elapsedMs: Date.now() - started};
		if (!result.ok && shotsDir) {
			result.screenshot = path.join(shotsDir, `${site.slug}__${publication.slug}.jpg`);
			await page.screenshot({path: result.screenshot, type: 'jpeg', quality: 50}).catch(() => {});
		}
		return result;
	} finally {
		await ctx.close();
	}
}

function describeRenderFailure(result, expected) {
	const {state, readerDocStatus} = result;
	if (state?.challenged) {
		return 'Cloudflare challenge page';
	}
	if (state?.hasSdkContainer) {
		const where = expected.readerUrl ? ` (${expected.readerUrl.replace(/\/page\/1$/, '')})` : '';
		const text = state.sdk?.text ? `: "${state.sdk.text}"` : '';
		return `Publitas reader ${readerDocStatus ?? 'did not load'}${where}${text}`;
	}
	if (state?.hasLegacyViewer) {
		return 'wepublish viewer shows a blank page';
	}
	return `no viewer rendered (ended on ${state?.path ?? 'unknown page'})`;
}

function bucketFor(viewer, rollout) {
	if (viewer === 'wepublish') {
		return 100;
	}
	if (viewer === 'sdk') {
		return 1;
	}
	return rollout > 0 ? 1 : null;
}

async function checkSite(site, ctx) {
	const {args, browser, overrideSlugs, readerHost, shotsDir, log} = ctx;
	const flags = await fetchFeatureFlags(site);
	const rollout = Math.min(100, Math.floor(Number(flags.sdkRolloutPercentage) || 0));
	let publications = await fetchLivePublications(site);
	if (args.only) {
		publications = publications.filter((p) => args.only.has(p.slug));
	}
	if (args.limit) {
		publications = publications.slice(0, args.limit);
	}
	const expectations = await pool(publications, 6, (p) =>
		fetchExpectedViewer(site, p, overrideSlugs, !!flags.enableForcedWepublishViewerOverrides)
	);
	const challenged = await isBehindChallenge(site.origin);
	const method = challenged ? 'http' : 'browser';
	const testedViewer = rollout > 0 ? (args.viewer === 'wepublish' ? 'wepublish' : 'sdk') : 'wepublish';
	log(
		`${site.slug}: ${publications.length} live, rollout ${rollout}%, ${method}${challenged ? ' (Cloudflare challenge)' : ''}`
	);

	const results = await pool(publications, args.concurrency, async (publication, i) => {
		const expected = expectations[i];
		const base = {
			site: site.slug,
			label: site.label,
			slug: publication.slug,
			name: publication.name,
			retailer: publication.retailer?.name ?? null,
			validFrom: publication.validFrom,
			validUntil: publication.validUntil,
			url: `${site.origin}${site.viewerPath}/${publication.slug}`,
			expected
		};
		if (method === 'http') {
			if (expected.expected !== 'sdk' || testedViewer !== 'sdk') {
				return {...base, status: 'not-render-checked', viewer: expected.expected};
			}
			let status = await checkReaderUrl(expected.readerUrl);
			if (status !== 200) {
				status = await checkReaderUrl(expected.readerUrl);
			}
			return status === 200
				? {...base, status: 'ok', viewer: 'sdk', readerStatus: status}
				: {...base, status: 'fail', viewer: 'sdk', readerStatus: status, cause: `Publitas reader ${status} (${expected.readerUrl.replace(/\/page\/1$/, '')})`};
		}
		const opts = {bucket: bucketFor(args.viewer, rollout), readerHost, shotsDir};
		let render = await renderCheck(browser, site, publication, opts);
		if (!render.ok) {
			render = await renderCheck(browser, site, publication, opts);
		}
		if (render.ok) {
			return {...base, status: 'ok', viewer: render.viewer};
		}
		const failure = {...base, status: 'fail', viewer: 'none', cause: describeRenderFailure(render, expected), screenshot: render.screenshot};
		if (render.state?.hasSdkContainer) {
			const onWepublish = await renderCheck(browser, site, publication, {...opts, bucket: 100});
			failure.wepublishOk = onWepublish.ok;
		}
		return failure;
	});

	const counts = {live: results.length, sdk: 0, wepublish: 0, fail: 0, notChecked: 0};
	for (const r of results) {
		if (r.status === 'fail') {
			counts.fail++;
		} else if (r.status === 'not-render-checked') {
			counts.notChecked++;
		} else {
			counts[r.viewer]++;
		}
	}
	log(`${site.slug}: ${counts.sdk} sdk, ${counts.wepublish} wepublish, ${counts.fail} failing, ${counts.notChecked} not render-checked`);
	return {site, rollout, method, testedViewer, counts, results};
}

function formatDate(iso) {
	return iso ? iso.slice(0, 10) : '';
}

function buildReport(siteReports, startedAt) {
	const lines = [];
	lines.push(`# Live publication check - ${startedAt.toISOString().slice(0, 16).replace('T', ' ')} UTC`, '');
	const totals = siteReports.reduce(
		(t, r) => {
			for (const k of Object.keys(t)) {
				t[k] += r.counts[k];
			}
			return t;
		},
		{live: 0, sdk: 0, wepublish: 0, fail: 0, notChecked: 0}
	);
	lines.push(
		`**${totals.live} live publications on ${siteReports.length} sites: ${totals.sdk} loaded in the SDK reader, ${totals.wepublish} in the wepublish viewer, ${totals.fail} failing${totals.notChecked ? `, ${totals.notChecked} not render-checked` : ''}.**`,
		''
	);

	const failing = siteReports.flatMap((r) => r.results.filter((x) => x.status === 'fail'));
	lines.push('## Failing publications', '');
	if (!failing.length) {
		lines.push('None.', '');
	}
	for (const report of siteReports) {
		const siteFailing = report.results.filter((x) => x.status === 'fail');
		if (!siteFailing.length) {
			continue;
		}
		const heading =
			report.site.label === report.site.slug ? report.site.slug : `${report.site.label} (${report.site.slug})`;
		lines.push(`### ${heading} - rollout ${report.rollout}%`, '');
		for (const f of siteFailing) {
			const validity = f.validFrom || f.validUntil ? `, valid ${formatDate(f.validFrom)} - ${formatDate(f.validUntil)}` : '';
			const elsewhere =
				f.wepublishOk === true ? ' - wepublish viewer OK' : f.wepublishOk === false ? ' - broken on wepublish viewer too' : '';
			lines.push(`- ${report.site.label} - ${f.slug} - ${f.url}`);
			lines.push(`  - ${f.retailer ?? 'unknown retailer'}${validity}. ${f.cause}${elsewhere}`);
		}
		lines.push('');
	}

	lines.push('## Per site', '');
	lines.push('| Site | Rollout | Method | Tested viewer | Live | SDK | wepublish | Failing | Not checked |');
	lines.push('|---|---|---|---|---|---|---|---|---|');
	for (const r of siteReports) {
		lines.push(
			`| ${r.site.slug} | ${r.rollout}% | ${r.method} | ${r.testedViewer} | ${r.counts.live} | ${r.counts.sdk} | ${r.counts.wepublish} | ${r.counts.fail} | ${r.counts.notChecked} |`
		);
	}
	lines.push('');

	const httpSites = siteReports.filter((r) => r.method === 'http');
	if (httpSites.length) {
		lines.push(
			`**Not rendered in a browser:** ${httpSites.map((r) => r.site.slug).join(', ')} serve headless browsers a Cloudflare challenge. ` +
				'For those, SDK publications were checked by the HTTP status of their Publitas reader page, and wepublish publications were not checked. ' +
				'A full render check needs a Cloudflare skip rule from Operations; do not try to bypass the challenge.',
			''
		);
	}
	const zeroRollout = siteReports.filter((r) => r.rollout === 0);
	if (zeroRollout.length) {
		lines.push(`Rollout is 0% on ${zeroRollout.map((r) => r.site.slug).join(', ')}, so only the wepublish viewer was tested there.`, '');
	}
	return lines.join('\n');
}

async function main() {
	const args = parseArgs();
	const startedAt = new Date();
	fs.mkdirSync(args.out, {recursive: true});
	const shotsDir = path.join(args.out, 'screenshots');
	fs.mkdirSync(shotsDir, {recursive: true});
	const logFile = path.join(args.out, 'progress.log');
	const log = (line) => {
		const stamped = `[${new Date().toISOString().slice(11, 19)}] ${line}`;
		console.log(stamped);
		fs.appendFileSync(logFile, `${stamped}\n`);
	};

	const sites = loadSites(args.sites);
	if (!sites.length) {
		throw new Error(`No sites match ${args.sites}`);
	}
	const domains = [...new Set([...sites.map((s) => s.publitasViewerDomain), 'view.publitas.com'])];
	const readerHost = new RegExp(`^https://(${domains.map((d) => d.replace(/\./g, '\\.')).join('|')})/`);
	log(`Checking ${sites.length} sites, output in ${args.out}`);

	const browser = await chromium.launch();
	const ctx = {args, browser, overrideSlugs: loadOverrideSlugs(), readerHost, shotsDir, log};
	const siteReports = [];
	try {
		for (const site of sites) {
			try {
				siteReports.push(await checkSite(site, ctx));
			} catch (error) {
				log(`${site.slug}: ERROR ${error.message}`);
			}
		}
	} finally {
		await browser.close();
	}

	fs.writeFileSync(
		path.join(args.out, 'results.json'),
		JSON.stringify(siteReports.map((r) => ({site: r.site.slug, rollout: r.rollout, method: r.method, counts: r.counts, results: r.results})), null, 1)
	);
	const report = buildReport(siteReports, startedAt);
	fs.writeFileSync(path.join(args.out, 'report.md'), report);
	console.log(`\n${report}`);
	console.log(`Report: ${path.join(args.out, 'report.md')}`);
}

main().catch((error) => {
	console.error(error);
	process.exit(1);
});
