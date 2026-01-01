#!/usr/bin/env bash

# Post-create setup for Claude CodePro devcontainer
# This script runs after the container is created

set -e

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "======================================================================"
echo "Setting up Claude CodePro development environment..."
echo "======================================================================"

# Fix Docker credentials issue - VS Code copies host's docker config with
# a credential helper that doesn't exist inside the container
if [ -f ~/.docker/config.json ] && grep -q "credsStore" ~/.docker/config.json 2>/dev/null; then
    echo "Fixing Docker credentials configuration..."
    echo '{}' > ~/.docker/config.json
fi

# Ensure bun is available in PATH for all shells (including /bin/sh used by hooks)
# The devcontainer feature installs bun to ~/.bun/bin but that's not in /bin/sh PATH
if [ -f "$HOME/.bun/bin/bun" ] && [ ! -f "/usr/local/bin/bun" ]; then
    echo "Adding bun to system PATH..."
    ln -sf "$HOME/.bun/bin/bun" /usr/local/bin/bun
    ln -sf "$HOME/.bun/bin/bunx" /usr/local/bin/bunx
fi

# Ensure node/npm/npx are available in PATH for all shells
# NVM installs to ~/.nvm but that PATH is only set in interactive shells
if [ -d "$HOME/.nvm" ]; then
    # Find the default node version
    NVM_NODE_PATH=$(find "$HOME/.nvm/versions/node" -maxdepth 1 -type d -name "v*" | sort -V | tail -1)
    if [ -n "$NVM_NODE_PATH" ] && [ -f "$NVM_NODE_PATH/bin/node" ]; then
        echo "Adding node/npm/npx to system PATH..."
        ln -sf "$NVM_NODE_PATH/bin/node" /usr/local/bin/node 2>/dev/null || true
        ln -sf "$NVM_NODE_PATH/bin/npm" /usr/local/bin/npm 2>/dev/null || true
        ln -sf "$NVM_NODE_PATH/bin/npx" /usr/local/bin/npx 2>/dev/null || true
    fi
fi

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
curl -fsSL https://qlty.sh | sh
echo -e "\nexport QLTY_INSTALL=\"\$HOME/.qlty\"" >> ~/.zshrc
echo -e 'export PATH=$QLTY_INSTALL/bin:$PATH' >> ~/.zshrc
"$HOME/.qlty/bin/qlty" check --install-only || true

# Install CodeRabbit CLI
echo "Installing CodeRabbit CLI..."
curl -fsSL https://cli.coderabbit.ai/install.sh | sh

# Install Claude Code CLI (before installer to avoid lock issues)
echo "Installing Claude Code CLI..."
rm -rf ~/.claude/.installing ~/.claude/*.lock 2>/dev/null || true
curl -fsSL https://claude.ai/install.sh | bash

# Run Claude CodePro installer from fork
echo "Running Claude CodePro installer..."
curl -fsSL https://raw.githubusercontent.com/tfvchow/claude-codepro/main/install.sh | bash

echo ""
echo "======================================================================"
echo "Dev Container setup complete!"
echo "======================================================================"
echo ""
echo "Next steps:"
echo "  1. Copy .env.codepro.template to .env.codepro and add your API keys"
echo "  2. Run 'ccp' to start Claude Code with CodePro configuration"
echo ""
