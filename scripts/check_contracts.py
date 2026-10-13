#!/usr/bin/env python3
"""Compare consumer views in sources/definitions/serve.sql against contracts/*.yml.

Breaking  = a contracted view is gone, or a contracted column is gone/renamed.
Safe      = new columns, new views.
Deprecated contracts are reported so consumers get notified.

Writes a markdown report to stdout. Exits 1 on breaking changes unless
ALLOW_BREAKING=true (set by the 'breaking-change' PR label).
"""
import glob
import os
import re
import sys

import yaml

SERVE_SQL = "sources/definitions/serve.sql"


def parse_views(sql):
    """Return {VIEW_NAME: [COLUMNS]} for each DEFINE VIEW ... SELECT ... FROM."""
    views = {}
    pattern = re.compile(
        r"DEFINE\s+VIEW\s+\S+\.SERVE\.(\w+).*?\bSELECT\b(.*?)\bFROM\b",
        re.IGNORECASE | re.DOTALL,
    )
    for name, select_list in pattern.findall(sql):
        cols = []
        for expr in select_list.split(","):
            expr = re.sub(r"--.*", "", expr).strip()
            if not expr:
                continue
            # "X AS Y" -> Y, otherwise the last identifier
            alias = re.split(r"\s+AS\s+", expr, flags=re.IGNORECASE)[-1]
            cols.append(alias.split(".")[-1].strip().upper())
        views[name.upper()] = cols
    return views


def main():
    with open(SERVE_SQL) as f:
        views = parse_views(f.read())

    breaking, notes = [], []
    for path in sorted(glob.glob("contracts/*.yml")):
        with open(path) as f:
            c = yaml.safe_load(f)
        view = c["view"].upper()
        consumers = ", ".join(c.get("consumers", []))
        if c.get("status") == "deprecated":
            notes.append(f"⚠️ `{view}` is **deprecated**. Notify consumers: {consumers}. "
                         f"Sunset: {c.get('sunset_date', 'TBD')}. Use `{c.get('replaced_by', '?')}`.")
        if view not in views:
            breaking.append(f"🚨 `{view}` was removed (consumers: {consumers})")
            continue
        missing = [col for col in c["columns"] if col.upper() not in views[view]]
        added = [col for col in views[view] if col not in [x.upper() for x in c["columns"]]]
        for col in missing:
            breaking.append(f"🚨 `{view}.{col}` was removed or renamed (consumers: {consumers})")
        for col in added:
            notes.append(f"✅ `{view}.{col}` is new (non-breaking)")

    for view in views:
        if not os.path.exists(f"contracts/{view.lower()}.yml"):
            notes.append(f"ℹ️ `{view}` has no contract yet. Add `contracts/{view.lower()}.yml`.")

    print("### Contract check")
    for line in notes + breaking:
        print(f"- {line}")
    if not breaking:
        print("\n✅ **No breaking changes.** Existing consumers are unaffected.")
        return
    if os.environ.get("ALLOW_BREAKING", "").lower() == "true":
        print("\n⚠️ Breaking changes approved via `breaking-change` label.")
        return
    print("\n❌ **Breaking changes detected.** Keep the old view and publish a new "
          "version instead, or add the `breaking-change` label.")
    sys.exit(1)


if __name__ == "__main__":
    main()
