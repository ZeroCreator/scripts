#!/usr/bin/env python3
"""Формирует и отправляет в Telegram список открытых задач ARMory."""
import os
import sqlite3
import subprocess
import sys
import tempfile
from datetime import datetime
from html import escape
from pathlib import Path


def db_path() -> Path:
    raw = os.environ.get("ARMORY_DB_PATH", "~/ARMory/data/armory.db")
    return Path(raw).expanduser()


def fetch_open_tasks(db: Path):
    conn = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    cur.execute(
        """
        SELECT
            t.id,
            t.title,
            t.priority,
            t.due_date,
            t.assignee_email,
            p.name AS project_name,
            s.name AS status_name
        FROM tasks t
        JOIN projects p ON p.id = t.project_id
        JOIN task_statuses s ON s.id = t.status_id
        WHERE t.is_closed = 0
        ORDER BY t.due_date IS NULL, t.due_date, t.id
        """
    )
    rows = cur.fetchall()
    conn.close()
    return rows


def format_message(tasks: list) -> str:
    if not tasks:
        return "📋 <b>ARMory:</b> открытых задач нет."

    lines = ["📋 <b>ARMory: открытые задачи</b>\n"]
    for task in tasks:
        due = task["due_date"]
        due_str = ""
        if due:
            try:
                dt = datetime.fromisoformat(due)
                due_str = f" (до {dt.strftime('%d.%m.%Y')})"
            except ValueError:
                due_str = f" (до {due})"
        assignee = task["assignee_email"] or "не назначен"
        lines.append(
            f"• <b>{escape(task['title'])}</b>\n"
            f"  Проект: {escape(task['project_name'])} | Статус: {escape(task['status_name'])}\n"
            f"  Приоритет: {escape(task['priority'])} | Исполнитель: {escape(assignee)}{due_str}"
        )
    return "\n\n".join(lines)


def send_message(text: str) -> int:
    script_dir = Path(__file__).resolve().parent
    sender = script_dir / "send_armory_telegram.sh"
    env_file = (script_dir / ".." / ".env").resolve()

    with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", suffix=".txt", delete=False) as tmp:
        tmp.write(text)
        message_file = Path(tmp.name)

    try:
        result = subprocess.run(
            [str(sender), str(message_file), str(env_file), "HTML"],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            print(result.stderr or result.stdout, file=sys.stderr)
            return result.returncode
        print(result.stdout)
        return 0
    finally:
        try:
            message_file.unlink()
        except OSError:
            pass


def main() -> int:
    db = db_path()
    if not db.exists():
        print(f"База ARMory не найдена: {db}", file=sys.stderr)
        return 1

    tasks = fetch_open_tasks(db)
    message = format_message(tasks)
    return send_message(message)


if __name__ == "__main__":
    sys.exit(main())
