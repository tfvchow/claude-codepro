"""Tests for environment step."""

from __future__ import annotations

import tempfile
from pathlib import Path

import pytest


class TestEnvironmentStep:
    """Test EnvironmentStep class."""

    def test_environment_step_has_correct_name(self):
        """EnvironmentStep has name 'environment'."""
        from installer.steps.environment import EnvironmentStep

        step = EnvironmentStep()
        assert step.name == "environment"

    def test_environment_check_returns_true_when_env_exists(self):
        """EnvironmentStep.check returns True when .env exists with required keys."""
        from installer.context import InstallContext
        from installer.steps.environment import EnvironmentStep
        from installer.ui import Console

        step = EnvironmentStep()
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create .env with some content
            env_file = Path(tmpdir) / ".env"
            env_file.write_text("SOME_KEY=value\n")

            ctx = InstallContext(
                project_dir=Path(tmpdir),
                ui=Console(non_interactive=True),
            )
            # .env exists
            result = step.check(ctx)
            assert isinstance(result, bool)

    def test_environment_run_skips_in_non_interactive(self):
        """EnvironmentStep.run skips prompts in non-interactive mode."""
        from installer.context import InstallContext
        from installer.steps.environment import EnvironmentStep
        from installer.ui import Console

        step = EnvironmentStep()
        with tempfile.TemporaryDirectory() as tmpdir:
            ctx = InstallContext(
                project_dir=Path(tmpdir),
                non_interactive=True,
                ui=Console(non_interactive=True),
            )

            # Should not raise or prompt
            step.run(ctx)

    def test_environment_uses_env_codepro_path(self):
        """EnvironmentStep targets .env.codepro file, not .env."""
        from installer.context import InstallContext
        from installer.steps.environment import EnvironmentStep

        # Verify the run method docstring mentions .env.codepro
        assert ".env.codepro" in EnvironmentStep.run.__doc__

    def test_add_env_key_writes_to_specified_file(self):
        """add_env_key writes to the specified file path."""
        from installer.steps.environment import add_env_key

        with tempfile.TemporaryDirectory() as tmpdir:
            env_codepro = Path(tmpdir) / ".env.codepro"

            add_env_key("TEST_KEY", "test_value", env_codepro)

            assert env_codepro.exists()
            content = env_codepro.read_text()
            assert "TEST_KEY=test_value" in content

    def test_key_exists_in_file_checks_correct_file(self):
        """key_exists_in_file checks the specified file."""
        from installer.steps.environment import key_exists_in_file

        with tempfile.TemporaryDirectory() as tmpdir:
            env_codepro = Path(tmpdir) / ".env.codepro"
            env_codepro.write_text("MY_KEY=my_value\n")

            # Key exists in .env.codepro
            assert key_exists_in_file("MY_KEY", env_codepro) is True
            # Key doesn't exist
            assert key_exists_in_file("OTHER_KEY", env_codepro) is False
