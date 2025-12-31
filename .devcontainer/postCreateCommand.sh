#!/usr/bin/env bash

# Post-create setup for Claude CodePro devcontainer
# This script runs after the container is created

set -e

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "======================================================================"
echo "Setting up Claude CodePro development environment..."
echo "======================================================================"

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

# Run upstream Claude CodePro installer
echo "Running Claude CodePro installer..."
curl -fsSL https://raw.githubusercontent.com/maxritter/claude-codepro/v3.2.11/install.sh | bash

echo ""
echo "======================================================================"
echo "Dev Container setup complete!"
echo "======================================================================"
echo ""
echo "Next steps:"
echo "  1. Copy .env.codepro.template to .env.codepro and add your API keys"
echo "  2. Run 'ccp' to start Claude Code with CodePro configuration"
echo ""
