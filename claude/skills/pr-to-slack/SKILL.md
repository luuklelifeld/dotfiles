---
name: pr-to-slack
description: Posts a pull request link to the #reach-pull-requests Slack channel at Publitas. Use whenever the user asks to share, post, announce, or send a PR to Slack, to "put this in the PR channel", to ask the team for a review on Slack, or says something like "post it in slack" right after a PR has been opened — even if they don't name the channel.
---

# Posting a PR to #reach-pull-requests

Channel: `#reach-pull-requests`, id `C057N3PM5HB` (Publitas workspace).

The channel is a **review queue**, not a changelog. People skim it looking for
something to pick up, so every message is one scannable line. Anything longer
makes the queue harder to read, and teammates push back on it.

## The format

One line: a bracketed repo tag, then the PR title as the link text.

```
[CP] [fix: three-level category pages query their parent category - #1451](https://github.com/publitas/reach-consumer-platforms/pull/1451)
```

That is the whole message. Post it with `slack_send_message` to `C057N3PM5HB`.

## Never add a description

Do not add a summary, an explanation of the bug, the root cause, what it fixes,
why it matters, or how it was found. Not a paragraph, not a sentence, not a
parenthetical. The PR description already holds all of that, and that is where
reviewers read it.

This is the single most important rule in this skill, and the easiest to get
wrong: a helpful-sounding sentence of context feels like an improvement and is
not. If the change genuinely needs framing, post the line, then reply **in the
thread** — that keeps the queue clean and still gets the context across.

## Repo tags

| Repo | Tag |
|---|---|
| `reach-consumer-platforms` | `[CP]` |
| `cp-api` | `[API]` |
| `cp-fmp` | `[FMP]` |
| `cp-p9n` | `[P9N]` |
| `cp-bundle-creator` | `[Bundle Creator]` |
| `cp-asset-creator` | `[Asset Creator]` |

Match the casing already used in the channel for that repo — read the last ~20
messages if unsure. Some people prefix a project as well, e.g.
`[Home Page Redesign][CP] fix: …`. Follow suit only when the user names a project.

## Several PRs for one change

When one change spans repos, use a bold one-line label, then one line per repo:

```
**Embedded carousel configuration**
[CP] [reach-consumer-platforms#1442](https://github.com/publitas/reach-consumer-platforms/pull/1442)
[API] [cp-api#1251](https://github.com/publitas/cp-api/pull/1251)
[FMP] [cp-fmp#687](https://github.com/publitas/cp-fmp/pull/687)
```

The label names the change in a few words. It is not a description of it.

## Asking for review

A short, human ask is fine and common — "Can someone please approve this?",
"Still looking for a review on these two". That is a request, not a summary of
the diff, so it doesn't conflict with the rule above. Keep it to one line.

## Steps

1. Get the PR title, number and URL — `gh pr view <n> --json title,number,url`,
   or from the URL the user gives you.
2. Map the repo to its tag.
3. Compose the single line and post it to `C057N3PM5HB`.
4. Return the Slack permalink.

If the user has not seen the exact text, prefer `slack_send_message_draft` so
they can eyeball it before it goes out.

## Known artifact

The connector appends `Sent using @Claude` to anything posted through it. That
footer is added by Slack when an app posts on someone's behalf and cannot be
suppressed from the message text. Posting manually, or through a workspace bot
token, are the only ways to avoid it — the bot token option posts as the app
rather than as the user.
