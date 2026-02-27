# AGENTS.md

## Purpose
This repository uses autonomous coding agents. Follow this file to keep changes predictable, testable, and easy to review.

## Default behavior
- Reply to the user in Russian unless they ask for another language.
- Keep edits minimal and task-focused.
- Do not change unrelated files.
- Never delete or modify verification files (for example `yandex_8a80c219526be083.html`) unless explicitly requested.

## Agent roles

### 1) Implementer agent
Use when adding or changing functionality.

Checklist:
- Confirm requirements and assumptions.
- Inspect current files before editing.
- Implement the smallest complete fix.
- Run relevant checks/tests.
- Provide a short change summary and test evidence.

### 2) Reviewer agent
Use for code review requests.

Checklist:
- Prioritize bugs, regressions, and missing tests.
- Report findings ordered by severity.
- Include file paths and exact affected lines.
- Keep summaries brief after findings.

### 3) Tester agent
Use when validating behavior manually or automatically.

Checklist:
- Define expected success criteria before running tests.
- Prefer targeted tests over full-suite runs.
- For UI changes, capture a short demo video and at least one screenshot.
- Report pass/fail with exact commands and outputs.

## Git workflow
- Work only on the current task branch.
- Commit small logical units with clear messages.
- Push after each meaningful completed step.
- Do not rewrite history unless asked.

## Testing policy
- Docs/text-only changes: verify file presence/content and formatting.
- Code changes: run the most specific existing tests that cover the change.
- If tests cannot run due to environment limitations, state the limitation clearly and include command output.

## Cursor Cloud specific instructions
- Start by checking `git status` and repository context.
- Prefer `rg` for search and targeted file reads for context gathering.
- Do not stop after implementation; always include testing evidence.
- Leave started services running unless cleanup is explicitly required.
- If a UI was changed, include a walkthrough artifact (video preferred).

## Definition of done
A task is complete only when all conditions are met:
- Requested change is implemented.
- Relevant checks/tests have been run.
- Results are communicated clearly.
- Changes are committed and pushed.
