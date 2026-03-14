#!/usr/bin/env python3
import argparse
import csv
from collections import deque
from dataclasses import dataclass
from datetime import date, datetime, timedelta
from pathlib import Path


def parse_bool(value: str) -> bool:
    return value.strip().lower() in {"1", "true", "yes", "y", "да"}


@dataclass
class Account:
    account_id: str
    daily_limit: int


@dataclass
class Contact:
    contact_id: str
    telegram: str
    display_name: str
    last_contact_date: date | None


def parse_date(raw: str) -> date | None:
    raw = raw.strip()
    if not raw:
        return None
    return datetime.strptime(raw, "%Y-%m-%d").date()


def load_accounts(path: Path) -> list[Account]:
    accounts: list[Account] = []
    with path.open("r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if not parse_bool(row.get("enabled", "false")):
                continue
            accounts.append(
                Account(
                    account_id=row["account_id"].strip(),
                    daily_limit=int(row["daily_limit"]),
                )
            )
    return accounts


def load_contacts(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def filter_contacts(raw_contacts: list[dict[str, str]], planned_date: date, cooldown_days: int) -> list[Contact]:
    ready: list[Contact] = []
    cooldown_delta = timedelta(days=max(0, cooldown_days))
    for row in raw_contacts:
        if not parse_bool(row.get("consent", "false")):
            continue
        telegram = row.get("telegram", "").strip()
        if not telegram:
            continue
        last_date = parse_date(row.get("last_contact_date", ""))
        if last_date is not None and planned_date - last_date < cooldown_delta:
            continue
        ready.append(
            Contact(
                contact_id=row["contact_id"].strip(),
                telegram=telegram,
                display_name=row.get("display_name", "").strip(),
                last_contact_date=last_date,
            )
        )
    return ready


def write_plan(out: Path, rows: list[dict[str, str]]) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["planned_date", "account_id", "contact_id", "telegram", "display_name"],
        )
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(description="Распределение контактов по аккаунтам с лимитами")
    parser.add_argument("--accounts", required=True, type=Path)
    parser.add_argument("--contacts", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--date", default=date.today().isoformat(), help="Дата плана в формате YYYY-MM-DD")
    parser.add_argument("--cooldown-days", type=int, default=2, help="Минимальная пауза между контактами (дни)")
    args = parser.parse_args()

    planned_date = datetime.strptime(args.date, "%Y-%m-%d").date()
    accounts = load_accounts(args.accounts)
    if not accounts:
        print("Нет активных аккаунтов.")
        return 1

    contacts = filter_contacts(load_contacts(args.contacts), planned_date, args.cooldown_days)
    if not contacts:
        print("Нет контактов, подходящих под правила.")
        write_plan(args.out, [])
        return 0

    queue = deque(accounts)
    account_remaining = {a.account_id: a.daily_limit for a in accounts}
    plan_rows: list[dict[str, str]] = []

    for contact in contacts:
        allocated = False
        for _ in range(len(queue)):
            account = queue[0]
            queue.rotate(-1)
            if account_remaining[account.account_id] <= 0:
                continue
            account_remaining[account.account_id] -= 1
            plan_rows.append(
                {
                    "planned_date": planned_date.isoformat(),
                    "account_id": account.account_id,
                    "contact_id": contact.contact_id,
                    "telegram": contact.telegram,
                    "display_name": contact.display_name,
                }
            )
            allocated = True
            break
        if not allocated:
            break

    write_plan(args.out, plan_rows)
    print(f"Сформировано заданий: {len(plan_rows)}")
    for acc in accounts:
        done = acc.daily_limit - account_remaining[acc.account_id]
        print(f"- {acc.account_id}: {done}/{acc.daily_limit}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

