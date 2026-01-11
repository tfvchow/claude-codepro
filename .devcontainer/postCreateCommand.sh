#!/usr/bin/env bash

# Post-create setup for Claude CodePro devcontainer
# This script runs after the container is created

set -e

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "======================================================================"
echo "Setting up Claude CodePro development environment..."
echo "======================================================================"

# Fix Docker credentials - remove host's credential helper that doesn't exist in container
if [ -f ~/.docker/config.json ] && command -v jq &> /dev/null; then
    jq 'del(.credsStore)' ~/.docker/config.json > ~/.docker/config.json.tmp && mv ~/.docker/config.json.tmp ~/.docker/config.json
fi

# Configure git identity (not mounted from host to avoid write conflicts)
git config --global user.name "Vincent Tsz-Fai Chow"
git config --global user.email "tfvchow@gmail.com"

# Setup Claude config symlink for credential persistence across rebuilds.
# Claude Code requires both /root/.claude/ dir and /root/.claude.json file.
# We store .claude.json inside the mounted volume and symlink to it.
[ -f /root/.claude/.claude.json ] || echo '{}' > /root/.claude/.claude.json
ln -sf /root/.claude/.claude.json /root/.claude.json

# Setup claude-mem data persistence across devcontainer rebuilds.
# claude-mem stores SQLite DB and vector DB in ~/.claude-mem/ which is NOT
# in the persisted volume. We symlink it to the persisted /root/.claude/ volume.
echo "Setting up claude-mem data persistence..."
CLAUDE_MEM_PERSIST="/root/.claude/claude-mem-data"
CLAUDE_MEM_DIR="/root/.claude-mem"

# Create target directory in persisted volume
mkdir -p "$CLAUDE_MEM_PERSIST"

# If .claude-mem exists as a real directory (not symlink), migrate data
if [ -d "$CLAUDE_MEM_DIR" ] && [ ! -L "$CLAUDE_MEM_DIR" ]; then
    echo "Migrating existing claude-mem data to persisted volume..."
    # Copy contents to persisted location (preserve existing data in target)
    cp -rn "$CLAUDE_MEM_DIR"/* "$CLAUDE_MEM_PERSIST"/ 2>/dev/null || true
    rm -rf "$CLAUDE_MEM_DIR"
fi

# Create symlink (remove stale symlink if exists)
[ -L "$CLAUDE_MEM_DIR" ] && rm "$CLAUDE_MEM_DIR"
ln -s "$CLAUDE_MEM_PERSIST" "$CLAUDE_MEM_DIR"
echo "claude-mem data will persist at $CLAUDE_MEM_PERSIST"

# Enable dotenv plugin for automatic .env loading
if ! grep -q "plugins=.*dotenv" ~/.zshrc 2>/dev/null; then
    echo "Configuring dotenv zsh plugin..."
    sed -i 's/plugins=(/plugins=(dotenv /' ~/.zshrc
    echo -e "\n# Auto-load .env files without prompting" >> ~/.zshrc
    echo 'export ZSH_DOTENV_PROMPT=false' >> ~/.zshrc
fi

# Install qlty (code quality tool)
echo "Installing qlty..."
if [ -d "${WORKSPACE_ROOT}/.qlty" ]; then
    find "${WORKSPACE_ROOT}/.qlty" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} + 2>/dev/null || true
    find "${WORKSPACE_ROOT}/.qlty" -mindepth 1 -maxdepth 1 -type l -delete 2>/dev/null || true
    find "${WORKSPACE_ROOT}/.qlty" -mindepth 1 -maxdepth 1 -type f ! -name 'qlty.toml' ! -name '.gitignore' -delete 2>/dev/null || true
fi
bash -c "$(curl -fsSL https://qlty.sh)"
echo -e "\nexport QLTY_INSTALL=\"\$HOME/.qlty\"" >> ~/.zshrc
echo -e 'export PATH=$QLTY_INSTALL/bin:$PATH' >> ~/.zshrc
"$HOME/.qlty/bin/qlty" check --install-only || true

# Install GitHub CLI for git operations
echo "Installing GitHub CLI..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list
apt-get update -qq && apt-get install gh -y -qq

# Install CodeRabbit CLI (use bash -c to ensure SHELL is set)
echo "Installing CodeRabbit CLI..."
bash -c "$(curl -fsSL https://cli.coderabbit.ai/install.sh)"

# Run Claude CodePro installer
# Detect if we're in the claude-codepro development repo or a target project
if [ -f "${WORKSPACE_ROOT}/installer/cli.py" ] && grep -q "claude-codepro" "${WORKSPACE_ROOT}/pyproject.toml" 2>/dev/null; then
    echo "Running Claude CodePro installer (local development mode)..."
    cd "${WORKSPACE_ROOT}" && uv run python -m installer.cli install --local
else
    echo "Running Claude CodePro installer..."
    cd "${WORKSPACE_ROOT}" && curl -fsSL https://raw.githubusercontent.com/tfvchow/claude-codepro/v4.1.4/install.sh | bash
fi

echo ""
echo "======================================================================"
echo "Dev Container setup complete!"
echo "======================================================================"
echo ""
echo "Next steps:"
echo "  1. Run 'ccp' to start Claude Code with CodePro configuration"
echo "     (You'll be prompted for API keys on first run if .env.codepro doesn't exist)"
echo ""
