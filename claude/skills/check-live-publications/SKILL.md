---
name: check-live-publications
description: Check that every live publication on production loads - folders.nl, promobutler.be (nl and fr) and every promozilla country - in the Publitas SDK reader or the wepublish fallback, and list the failing ones per country with URLs. Use when asked to check, test or verify live publications, flyers or folders, to check the reader SDK rollout, or to find publications that do not load.
---

# Check live publications

`check-live-publications.mjs` (next to this file) loads every live publication on production and reports which ones
fail to render, grouped per site/country with their URLs and the likely cause.

## Run it

It takes about 30 minutes for all ~2,000 publications, so run it with `run_in_background` and wait for the
completion notification instead of polling. Write the output to the scratchpad directory.

```bash
node .claude/skills/check-live-publications/check-live-publications.mjs --out <scratchpad>/publication-check
```

| Option          | Default | Use                                                                                                     |
| --------------- | ------- | ------------------------------------------------------------------------------------------------------- |
| `--sites`       | all     | Comma-separated config slugs or prefixes: `promozilla`, `promozilla-mx`, `promobutler-be`, `folders-nl` |
| `--only`        | all     | Comma-separated publication slugs, e.g. to re-check last run's failures                                 |
| `--viewer`      | `auto`  | `auto`/`sdk`: force the SDK reader wherever rollout is above 0%. `wepublish`: force the fallback viewer |
| `--limit`       | none    | First N publications per site, for a quick smoke run                                                    |
| `--concurrency` | 8       | Parallel browser pages                                                                                  |

If Chromium is missing: `npx playwright install chromium`.

## What it does

- Sites come from `affiliate/configs`: `folders-nl`, `promobutler-be-nl`, `promobutler-be-fr` and every
  `promozilla-xx` (new countries are picked up automatically). Live publications come from the production API
  (`excludeExpired`, `excludePlanned`).
- The SDK is forced with the `reader-sdk-bucket-<affiliate>` cookie set to 1. That only works where
  `sdkRolloutPercentage` is above 0; at 0% (folders.nl today) the wepublish viewer is tested instead.
- Pass: page images render in the Publitas iframe, or the wepublish canvas draws a page. Each failure is retried
  once. A failure in the SDK reader is then loaded once more in the wepublish viewer, so the report can tell
  "SDK only" apart from "broken everywhere".
- For each publication, the API data predicts which viewer it should use. A publication falls back by design if
  it has no Publitas slug, belongs to another Publitas account, is expired, or is on `OVERRIDE_SLUGS`
  (`src/utils/feature-flag.utils.ts`). Falling back is a pass.

Output in `--out`: `report.md` (also printed at the end), `results.json`, `progress.log` and a screenshot of every
failure.

## Report back

Relay the **Failing publications** section of `report.md` as-is: it is a copyable bullet list per country with
URLs and causes. Add the totals line and any "not rendered in a browser" or 0%-rollout notes. Say how many
failures are SDK-only (the wepublish viewer is OK) and which are broken everywhere, and keep the rest short.

Typical causes:

- `Publitas reader 404` - wepublish lists the publication as live, but it does not exist (any more, or yet) on
  Publitas. The app does not fall back on a 404, so SDK users see "publication not found" or a blank frame. Check
  the validity dates: a publication that starts later or expires today is usually a timing mismatch, not a bug.
- `Publitas reader 502` that passes on retry - transient. Persistent 502s are worth reporting.
- `wepublish viewer shows a blank page` - the publication's own data is broken.

## Rules

- **Do not remove the tracking/ad blocking.** Every run loads ~2,000 production pages. Without the blocking, they
  inflate retailers' Publitas stats, send bot ad impressions and flood Sentry and PostHog.
- **Do not bypass Cloudflare.** promobutler.be serves headless browsers a challenge. The script detects it and falls
  back to checking the HTTP status of each Publitas reader page, and it cannot render-check wepublish
  publications there. Do not work around the challenge with stealth plugins, spoofed headers, cookies from a real
  browser or similar. If a full render check is needed, tell the user to ask Operations for a Cloudflare skip rule.
- Only GraphQL queries run against production; the script aborts mutations.
