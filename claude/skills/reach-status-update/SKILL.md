---
name: reach-status-update
description: Writes and posts the bi-weekly Reach Engineering sprint status update to the "Reach Engineering" Asana project, with throughput, cycle time and change failure rate charts from the Databricks dev_metrics data. Use when the user asks for the Reach status update, sprint update, engineering metrics update, or works on the recurring "Reach Engineering status update" Asana task.
---

# Reach Engineering status update

Posted to Asana project **Reach Engineering** (gid `1213212201189126`) after each sprint closes. The recurring
reminder task is `1213593653858851`.

Covers the **last closed sprint** (`sprint_state = 'closed'`), never the active one.

## 1. Pull the data (Databricks Genie MCP)

Use `mcp__claude_ai_Databricks__query_space_01f110b19aa719719311c2aa0d4c9d1f`, then poll with
`mcp__claude_ai_Databricks__poll_response_01f110b19aa719719311c2aa0d4c9d1f` until `COMPLETED`. Ask for exact SQL
so Genie doesn't improvise:

```sql
SELECT sprint_name, start_date, end_date, tickets_committed, tickets_completed, prs_merged, failures,
       ticket_cycle_time_p50, ticket_cycle_time_p90, pr_lead_time_p50, pr_lead_time_p90, change_failure_rate
FROM dev_metrics.default.sprint_metrics
WHERE team = 'reach' AND sprint_state = 'closed'
ORDER BY start_date DESC
LIMIT 9
```

Check the SQL Genie actually ran (in `queryAttachments[].query`) matches this. Cycle/lead times are in **days**
(Genie claims hours - it is wrong; PR lead p50 is ~0 and ticket lead p90 ~200). `change_failure_rate` is
`failures / prs_merged` as a percentage.

## 2. Render the charts

Write the rows **oldest first** as a JSON array (numbers as numbers) to `<scratchpad>/metrics.json`, then:

```bash
~/.claude/skills/reach-status-update/.venv/bin/python ~/.claude/skills/reach-status-update/scripts/render_charts.py \
  <scratchpad>/metrics.json <scratchpad>/charts
```

If `.venv` is missing: `python3 -m venv ~/.claude/skills/reach-status-update/.venv && ~/.claude/skills/reach-status-update/.venv/bin/pip install matplotlib`.

Outputs `1-throughput.png`, `2-ticket-cycle-time.png`, `3-pr-lead-time.png`, `4-change-failure-rate.png`. Read each
PNG to sanity-check it before moving on.

## 3. Draft

Title: `Reach Engineering - <Mon D>` using today's date (e.g. `Reach Engineering - Sep 15`).

Structure (mirror previous updates; read the current one via `get_project` with
`opt_fields=current_status_update.title,current_status_update.text` to match tone):

```
Throughput
_Committed: <n> - Completed: <n>_
<1-2 sentences>
[chart 1]

Cycle times
_Ticket cycle time p50: <n>d - p90: <n>d_
_PR lead time p50: <n>d - p90: <n>d_
<1 sentence on ticket cycle + PR lead time trend>
[chart 2]
[chart 3]

Change failure rate
_Failures: <n> - PRs merged: <n> - Rate: <n>%_
<1 sentence; name the incident(s) if any>
[chart 4]
```

The `_..._` number line under each header is italic (`<em>`) - Asana has no smaller text size.

Commentary rules:
- Compare against the previous sprints, not in isolation. Short. The last update's tone is casual ("Back to no
  incidents 🥳").
- Don't invent causes. When something stands out (low completion rate, cycle-time spike, any failure), **ask the
  user** why before writing it - they know the retro outcome and which incident caused a failure.
- Color: `green` by default. Suggest `yellow` only if the user describes a real delivery risk; the metrics alone
  don't decide it.

Asana status updates have no draft state - creating one publishes it and notifies project members. So the draft
goes into the **description of the reminder task** `1213593653858851` (only the user follows it, it's in no
project): `update_tasks` with `html_notes`, title + color at the top, then `<hr/>`, then the body with
`<strong>` section headers and `<em>[chart: ...]</em>` placeholders. Check the description is empty or an old
draft before overwriting. Then `open <scratchpad>/charts` and give the user the task link.

The user reviews there and posts it themselves (copy into a new status update, drag the PNGs over the
placeholders). Only post via the API (step 4) if they explicitly ask you to.


## 4. Post (only on explicit request)

`mcp__claude_ai_Asana__create_project_status_update` with `parent: "1213212201189126"`, the title, color, and
`html_text`. Allowed tags only: `<body>`, `<strong>`, `<em>`, `<ul>`, `<li>`, `<a>` etc. - no headings, no `<img>`.
Section headers as `<strong>`, a blank line between sections. Put a placeholder line where each chart goes, e.g.
`<em>[chart: throughput]</em>`, so the user knows where to drop them.

The Asana API cannot embed images in status updates. After posting:
1. `open <scratchpad>/charts` so Finder shows the PNGs.
2. Give the user the update's `permalink_url` and tell them to edit it and replace each placeholder with its PNG.

## 5. Close out (only after the user confirms it's done)

Never complete task `1213593653858851` - it's reused every sprint. Only once the user confirms the update is
posted/done, set its `due_on` to the Wednesday two weeks after the current sprint's Wednesday (sprints start
Wednesdays; e.g. update on Thu Sep 24 → due Wed Oct 7). Don't touch the due date before that confirmation.
