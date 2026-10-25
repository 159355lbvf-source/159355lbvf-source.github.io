# AGENTS.md

## Cursor Cloud specific instructions

### Overview

This is a lightweight Telegram outreach orchestration toolkit (`safe_outreach/`). It consists of Python 3 CLI scripts that use **only the standard library** (no third-party dependencies). There are no servers, databases, or long-running processes.

### Prerequisites

- **Python 3.10+** (uses `type | None` union syntax from PEP 604)
- **Bash** (for `run_daily.sh`)
- **Git** (the `fanout_command.py` tool runs shell commands across agent repos)

### Running the tools

All commands are documented in `safe_outreach/README.md`. Key entry points:

| Tool | Command |
|------|---------|
| Fan-out command | `python3 safe_outreach/tools/fanout_command.py --repos safe_outreach/config/repos.txt --command "git status --short"` |
| Plan daily contacts | `python3 safe_outreach/tools/plan_daily_contacts.py --accounts safe_outreach/config/accounts.csv --contacts safe_outreach/config/contacts.csv --out safe_outreach/out/assignments.csv --date YYYY-MM-DD` |
| Render drafts | `python3 safe_outreach/tools/render_message_drafts.py --assignments safe_outreach/out/assignments.csv --template safe_outreach/templates/default_message.txt --out-dir safe_outreach/out/drafts` |
| Full daily pipeline | `bash safe_outreach/tools/run_daily.sh [YYYY-MM-DD]` |

### Non-obvious notes

- The `fanout_command.py` tool expects 20 agent repositories at `/workspace/agents/repo_01..20`. These are **not part of the repo** (`.gitignore` excludes `agents/`). The tool reports `ERR(2)` for missing paths but continues to process all repos.
- `run_daily.sh` uses `set -euo pipefail`, so it will exit with code 1 if `fanout_command.py` reports any failures (e.g., missing agent repos). Steps 2 and 3 (plan + drafts) only run if step 1 succeeds.
- Output files go to `safe_outreach/out/` which is created automatically and excluded by `.gitignore`.
- The `contacts.csv` filter excludes contacts without `consent=true`, without a `telegram` handle, and those contacted within the cooldown window (default: 2 days).
- No linter or test framework is configured in this repo. Use `python3 -m py_compile <file>` for syntax checking and `bash -n <script>` for shell script validation.
