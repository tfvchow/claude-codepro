"""Environment step - sets up .env.codepro file with API keys."""

from __future__ import annotations

import os
import shutil
from pathlib import Path
from typing import TYPE_CHECKING

from installer.steps.base import BaseStep

if TYPE_CHECKING:
    from installer.context import InstallContext


# Keys to remove from old .env files during migration
OBSOLETE_ENV_KEYS = [
    "MILVUS_TOKEN",
    "VECTOR_STORE_USERNAME",
    "VECTOR_STORE_PASSWORD",
    "EXA_API_KEY",
    "GEMINI_API_KEY",
]

# Claude CodePro specific keys (belong in .env.codepro, not .env)
CODEPRO_KEYS = [
    ("OPENAI_API_KEY", "Semantic Code Search", "https://platform.openai.com/api-keys"),
    ("TAVILY_API_KEY", "AI Web Search", "https://app.tavily.com/home"),
    ("REF_API_KEY", "Library Docs", "https://ref.tools/dashboard"),
]

LOCAL_MILVUS_ADDRESS = "http://host.docker.internal:19530"
ENV_CODEPRO_FILE = ".env.codepro"
ENV_CODEPRO_TEMPLATE = ".env.codepro.template"


def remove_env_key(key: str, env_file: Path) -> bool:
    """Remove an environment key from .env file. Returns True if key was removed."""
    if not env_file.exists():
        return False

    lines = env_file.read_text().splitlines()
    new_lines = [line for line in lines if not line.strip().startswith(f"{key}=")]

    if len(new_lines) != len(lines):
        env_file.write_text("\n".join(new_lines) + "\n" if new_lines else "")
        return True
    return False


def set_env_key(key: str, value: str, env_file: Path) -> None:
    """Set an environment key in .env file, replacing if it exists."""
    if not env_file.exists():
        env_file.write_text(f"{key}={value}\n")
        return

    lines = env_file.read_text().splitlines()
    new_lines = [line for line in lines if not line.strip().startswith(f"{key}=")]
    new_lines.append(f"{key}={value}")
    env_file.write_text("\n".join(new_lines) + "\n")


def cleanup_obsolete_env_keys(env_file: Path) -> list[str]:
    """Remove obsolete environment keys from .env file. Returns list of removed keys."""
    removed = []
    for key in OBSOLETE_ENV_KEYS:
        if remove_env_key(key, env_file):
            removed.append(key)
    return removed


def key_exists_in_file(key: str, env_file: Path) -> bool:
    """Check if key exists in .env file with a non-empty value."""
    if not env_file.exists():
        return False

    content = env_file.read_text()
    for line in content.split("\n"):
        line = line.strip()
        if line.startswith(f"{key}="):
            value = line[len(key) + 1 :].strip()
            return bool(value)
    return False


def key_is_set(key: str, env_file: Path) -> bool:
    """Check if key exists in .env file OR is already set as environment variable."""
    if os.environ.get(key):
        return True
    return key_exists_in_file(key, env_file)


def add_env_key(key: str, value: str, env_file: Path) -> None:
    """Add environment key to .env file if it doesn't exist."""
    if key_exists_in_file(key, env_file):
        return

    with open(env_file, "a") as f:
        f.write(f"{key}={value}\n")


class EnvironmentStep(BaseStep):
    """Step that sets up the .env.codepro file for Claude CodePro API keys."""

    name = "environment"

    def check(self, ctx: InstallContext) -> bool:
        """Check if .env.codepro exists with required keys."""
        env_file = ctx.project_dir / ENV_CODEPRO_FILE
        if not env_file.exists():
            return False
        # Check if at least one key is set
        return any(key_is_set(key, env_file) for key, _, _ in CODEPRO_KEYS)

    def run(self, ctx: InstallContext) -> None:
        """Set up .env.codepro file with Claude CodePro API keys."""
        ui = ctx.ui
        env_file = ctx.project_dir / ENV_CODEPRO_FILE
        template_file = ctx.project_dir / ENV_CODEPRO_TEMPLATE

        if ctx.skip_env or ctx.non_interactive:
            if ui:
                ui.status("Skipping .env.codepro setup")
            return

        if ui:
            ui.section("Claude CodePro API Keys")

        # Copy from template if .env.codepro doesn't exist
        if not env_file.exists():
            if template_file.exists():
                shutil.copy(template_file, env_file)
                if ui:
                    ui.success(f"Created {ENV_CODEPRO_FILE} from template")
            else:
                env_file.touch()
                if ui:
                    ui.success(f"Created {ENV_CODEPRO_FILE}")
        else:
            if ui:
                ui.success(f"Found existing {ENV_CODEPRO_FILE}")

        # Clean up obsolete keys from old .env file (migration)
        old_env_file = ctx.project_dir / ".env"
        if old_env_file.exists():
            removed_keys = cleanup_obsolete_env_keys(old_env_file)
            if removed_keys and ui:
                ui.print(f"  [dim]Removed obsolete keys from .env: {', '.join(removed_keys)}[/dim]")

        # Prompt for missing keys
        if ui:
            ui.print()
            ui.print("  Checking for missing API keys...")
            ui.print()

        missing_count = 0
        for idx, (key, desc, url) in enumerate(CODEPRO_KEYS, 1):
            if key_is_set(key, env_file):
                if ui:
                    ui.success(f"{key} already set")
                continue

            missing_count += 1
            if ui:
                ui.print()
                ui.rule(f"{idx}. {key} - {desc}")
                ui.print()
                ui.print(f"  [bold]Create at:[/bold] [cyan]{url}[/cyan]")
                ui.print()

                value = ui.input(key, default="")
                if value:  # Only add non-empty values
                    add_env_key(key, value, env_file)
                    ui.success(f"Added {key}")
                else:
                    ui.warning(f"Skipped {key} (empty)")

        # Always ensure MILVUS_ADDRESS is set
        set_env_key("MILVUS_ADDRESS", LOCAL_MILVUS_ADDRESS, env_file)

        if ui:
            ui.print()
            if missing_count == 0:
                ui.success("All Claude CodePro API keys are configured")
            else:
                ui.success(f"Updated {ENV_CODEPRO_FILE}")
            ui.print()
            ui.print(f"  [dim]Note: Your project .env file remains untouched.[/dim]")
            ui.print(f"  [dim]Claude CodePro uses {ENV_CODEPRO_FILE} for its own keys.[/dim]")

    def rollback(self, ctx: InstallContext) -> None:
        """No rollback for environment setup."""
        pass
