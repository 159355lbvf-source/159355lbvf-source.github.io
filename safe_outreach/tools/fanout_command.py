#!/usr/bin/env python3
import argparse
import concurrent.futures
import subprocess
from dataclasses import dataclass
from pathlib import Path


@dataclass
class RepoResult:
    repo: Path
    returncode: int
    stdout: str
    stderr: str


def read_repos(repos_file: Path) -> list[Path]:
    repos: list[Path] = []
    for raw in repos_file.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        repos.append(Path(line).expanduser())
    return repos


def run_command(repo: Path, command: str) -> RepoResult:
    if not repo.exists():
        return RepoResult(repo=repo, returncode=2, stdout="", stderr="Путь не существует")
    completed = subprocess.run(
        command,
        shell=True,
        cwd=str(repo),
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    return RepoResult(
        repo=repo,
        returncode=completed.returncode,
        stdout=completed.stdout.strip(),
        stderr=completed.stderr.strip(),
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Запуск одной команды во всех репозиториях")
    parser.add_argument("--repos", required=True, type=Path, help="Файл со списком путей к репозиториям")
    parser.add_argument("--command", required=True, help="Команда для запуска")
    parser.add_argument("--jobs", type=int, default=4, help="Количество параллельных задач")
    args = parser.parse_args()

    repos = read_repos(args.repos)
    if not repos:
        print("Список репозиториев пуст.")
        return 1

    print(f"Запускаю команду в {len(repos)} репозиториях...")
    results: list[RepoResult] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=max(1, args.jobs)) as executor:
        futures = [executor.submit(run_command, repo, args.command) for repo in repos]
        for future in concurrent.futures.as_completed(futures):
            results.append(future.result())

    failures = 0
    for result in sorted(results, key=lambda r: str(r.repo)):
        status = "OK" if result.returncode == 0 else f"ERR({result.returncode})"
        print(f"\n[{status}] {result.repo}")
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)
        if result.returncode != 0:
            failures += 1

    print(f"\nИтог: успешно={len(results) - failures}, с ошибками={failures}")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())

