#!/bin/bash
# Runs the trainer locally at http://127.0.0.1:8124
# On first run it creates a .venv folder and installs Flask into it.
set -e
cd "$(dirname "$0")"

if ! .venv/bin/python -c "import flask" 2>/dev/null; then
  echo "מתקין בפעם הראשונה (כמה שניות)..."
  rm -rf .venv
  python3 -m venv .venv
  .venv/bin/python -m pip install -q --disable-pip-version-check -r requirements.txt
fi

export PORT="${PORT:-8124}"
exec .venv/bin/python spanish_web.py
