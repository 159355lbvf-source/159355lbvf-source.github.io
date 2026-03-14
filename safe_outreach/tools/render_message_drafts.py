#!/usr/bin/env python3
import argparse
import csv
from collections import defaultdict
from pathlib import Path


def load_assignments(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def render_message(template: str, row: dict[str, str]) -> str:
    return template.format(
        display_name=row.get("display_name", "").strip() or "друг",
        telegram=row.get("telegram", "").strip(),
        contact_id=row.get("contact_id", "").strip(),
        account_id=row.get("account_id", "").strip(),
        planned_date=row.get("planned_date", "").strip(),
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Генерация черновиков сообщений для ручной отправки")
    parser.add_argument("--assignments", required=True, type=Path)
    parser.add_argument("--template", required=True, type=Path)
    parser.add_argument("--out-dir", required=True, type=Path)
    args = parser.parse_args()

    rows = load_assignments(args.assignments)
    template = args.template.read_text(encoding="utf-8")
    grouped: dict[str, list[dict[str, str]]] = defaultdict(list)
    for row in rows:
        grouped[row["account_id"]].append(row)

    args.out_dir.mkdir(parents=True, exist_ok=True)

    total = 0
    for account_id, items in grouped.items():
        lines: list[str] = [f"# Черновики для {account_id}", ""]
        for idx, row in enumerate(items, start=1):
            lines.append(f"## {idx}. {row.get('telegram', '')}")
            lines.append(render_message(template, row))
            lines.append("")
        out_path = args.out_dir / f"{account_id}_drafts.txt"
        out_path.write_text("\n".join(lines).strip() + "\n", encoding="utf-8")
        total += len(items)
        print(f"Создано: {out_path} ({len(items)} шт.)")

    print(f"Итого черновиков: {total}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

