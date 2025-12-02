"""Tests for install.sh bootstrap script."""

from __future__ import annotations

from pathlib import Path


def test_install_sh_runs_install_command():
    """Verify install.sh passes 'install' command to the binary."""
    install_sh = Path(__file__).parent.parent.parent / "install.sh"
    content = install_sh.read_text()

    # The script must run the binary with 'install' command
    assert "install" in content, "install.sh must pass 'install' command to binary"

    # Check that the script runs INSTALL_PATH with 'install' command
    assert "$INSTALL_PATH" in content, "Script must reference INSTALL_PATH variable"
    assert 'install "$@"' in content or "install --non-interactive" in content, "Script must pass install command"


def test_install_sh_is_executable_bash_script():
    """Verify install.sh has proper shebang."""
    install_sh = Path(__file__).parent.parent.parent / "install.sh"
    content = install_sh.read_text()

    assert content.startswith("#!/bin/bash"), "install.sh must start with bash shebang"
