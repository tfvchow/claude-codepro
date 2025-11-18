"""
Claude CodePro Installation Library

This package contains modular components for the Claude CodePro installation system.
Each module provides specific functionality for installing and configuring the environment.
"""

__version__ = "3.0.0"  # Python rewrite version

# Import all modules
from . import (
    dependencies,
    devcontainer,
    downloads,
    env_setup,
    files,
    migration,
    shell_config,
    ui,
    utils,
)

__all__ = [
    "dependencies",
    "devcontainer",
    "downloads",
    "env_setup",
    "files",
    "migration",
    "shell_config",
    "ui",
    "utils",
]
