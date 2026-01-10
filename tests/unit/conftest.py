"""Pytest configuration for unit tests."""

from __future__ import annotations

import sys
from pathlib import Path

# Add .claude/scripts to Python path so claude_scripts can be imported
scripts_dir = Path(__file__).parent.parent.parent / ".claude" / "scripts"
if str(scripts_dir.parent) not in sys.path:
    sys.path.insert(0, str(scripts_dir.parent))

# Also make .claude a package name alias
claude_scripts_parent = scripts_dir.parent
if str(claude_scripts_parent) not in sys.path:
    sys.path.insert(0, str(claude_scripts_parent))
