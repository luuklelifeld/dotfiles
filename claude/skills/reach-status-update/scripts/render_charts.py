"""Render Reach sprint metric charts as PNGs.

Usage: render_charts.py <metrics.json> <out_dir>

metrics.json: list of closed sprints, oldest first, each with keys
sprint_name, tickets_committed, tickets_completed, ticket_cycle_time_p50,
ticket_cycle_time_p90, pr_lead_time_p50, pr_lead_time_p90, prs_merged,
failures, change_failure_rate.
"""

import json
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

COMMITTED = "#9aa5b1"
COMPLETED = "#2a7de1"
P50 = "#2a7de1"
P90 = "#e8833a"
FAILURE = "#d64545"


def short_label(sprint_name):
    return sprint_name.replace("Reach Sprint ", "S")


def new_axes(title):
    fig, ax = plt.subplots(figsize=(8, 3.6), dpi=150)
    ax.set_title(title, loc="left", fontsize=12, fontweight="bold")
    ax.spines[["top", "right"]].set_visible(False)
    ax.grid(axis="y", alpha=0.3)
    ax.set_axisbelow(True)
    return fig, ax


def save(fig, out_dir, name):
    fig.tight_layout()
    path = out_dir / name
    fig.savefig(path)
    plt.close(fig)
    print(path)


def throughput(rows, labels, out_dir):
    fig, ax = new_axes("Throughput (tickets)")
    x = range(len(rows))
    width = 0.4
    committed = [r["tickets_committed"] for r in rows]
    completed = [r["tickets_completed"] for r in rows]
    ax.bar([i - width / 2 for i in x], committed, width, label="Committed", color=COMMITTED)
    bars = ax.bar([i + width / 2 for i in x], completed, width, label="Completed", color=COMPLETED)
    ax.bar_label(bars, fontsize=8)
    ax.set_xticks(list(x), labels)
    ax.legend(frameon=False, loc="lower right", bbox_to_anchor=(1, 1), ncols=2)
    save(fig, out_dir, "1-throughput.png")


def percentile_lines(rows, labels, out_dir, key, title, filename):
    fig, ax = new_axes(title)
    for suffix, color, label_offset in (("p50", P50, -12), ("p90", P90, 6)):
        values = [r[f"{key}_{suffix}"] for r in rows]
        ax.plot(labels, values, marker="o", color=color, label=suffix)
        for label, value in zip(labels, values):
            ax.annotate(str(value), (label, value), textcoords="offset points", xytext=(0, label_offset), ha="center", fontsize=8)
    ax.set_ylabel("days")
    ax.set_ylim(bottom=-0.5)
    ax.legend(frameon=False, loc="lower right", bbox_to_anchor=(1, 1), ncols=2)
    save(fig, out_dir, filename)


def change_failure_rate(rows, labels, out_dir):
    fig, ax = new_axes("Change failure rate")
    rates = [r["change_failure_rate"] for r in rows]
    bars = ax.bar(labels, rates, color=FAILURE)
    ax.bar_label(bars, labels=[f"{r['failures']}/{r['prs_merged']}" for r in rows], fontsize=8)
    ax.set_ylabel("% of merged PRs")
    ax.set_ylim(0, max(max(rates) * 1.25, 10))
    save(fig, out_dir, "4-change-failure-rate.png")


def main():
    rows = json.loads(Path(sys.argv[1]).read_text())
    out_dir = Path(sys.argv[2])
    out_dir.mkdir(parents=True, exist_ok=True)
    labels = [short_label(r["sprint_name"]) for r in rows]
    throughput(rows, labels, out_dir)
    percentile_lines(rows, labels, out_dir, "ticket_cycle_time", "Ticket cycle time", "2-ticket-cycle-time.png")
    percentile_lines(rows, labels, out_dir, "pr_lead_time", "PR lead time", "3-pr-lead-time.png")
    change_failure_rate(rows, labels, out_dir)


if __name__ == "__main__":
    main()
