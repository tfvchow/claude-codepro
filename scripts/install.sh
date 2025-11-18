#!/bin/bash

# =============================================================================
# Claude CodePro Installation Entry Point
# This is a minimal wrapper that checks for Python 3 and runs install.py
# Supports: macOS, Linux, WSL
# =============================================================================

set -e

# Repository configuration
REPO_URL="https://github.com/maxritter/claude-codepro"
REPO_BRANCH="main"

# Color codes for output
RED='\033[0;31m'
BLUE='\033[0;36m'
NC='\033[0m'

# Print functions
print_error() {
	echo -e "${RED}✗ $1${NC}" >&2
}

print_info() {
	echo -e "${BLUE}ℹ $1${NC}"
}

# Check for Python 3
check_python3() {
	if ! command -v python3 &>/dev/null; then
		print_error "Python 3 is required but not found"
		echo ""
		echo "Please install Python 3.8 or later:"
		echo ""
		echo "  macOS:   brew install python3"
		echo "  Ubuntu:  sudo apt-get install python3"
		echo "  Fedora:  sudo dnf install python3"
		echo ""
		exit 1
	fi

	# Check Python version is at least 3.8
	local python_version
	python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
	local major
	major=$(echo "$python_version" | cut -d. -f1)
	local minor
	minor=$(echo "$python_version" | cut -d. -f2)

	if [[ $major -lt 3 ]] || [[ $major -eq 3 && $minor -lt 8 ]]; then
		print_error "Python 3.8 or later is required (found: Python $python_version)"
		exit 1
	fi
}

# Download install.py from GitHub
download_install_py() {
	local dest_file=$1
	local install_py_url="${REPO_URL}/raw/${REPO_BRANCH}/scripts/install.py"

	print_info "Downloading install.py from GitHub..."
	if command -v curl &>/dev/null; then
		if ! curl -sL --fail "$install_py_url" -o "$dest_file"; then
			print_error "Failed to download install.py"
			exit 1
		fi
	elif command -v wget &>/dev/null; then
		if ! wget -q "$install_py_url" -O "$dest_file"; then
			print_error "Failed to download install.py"
			exit 1
		fi
	else
		print_error "Neither curl nor wget found. Please install one of them."
		exit 1
	fi
}

# Main execution
main() {
	# Check for Python 3
	check_python3

	# Detect local repo directory (script location)
	local script_location
	script_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	local local_repo_dir
	local_repo_dir="$(cd "$script_location/.." && pwd)"
	local local_install_py="$local_repo_dir/scripts/install.py"

	# Determine if we're running in local mode
	local local_mode=false
	local install_py_path=""

	# Check if --local flag is present OR if install.py exists locally
	for arg in "$@"; do
		if [[ $arg == "--local" ]]; then
			local_mode=true
			break
		fi
	done

	# Auto-detect local mode if install.py exists at expected location
	if [[ -f $local_install_py ]]; then
		local_mode=true
	fi

	# If running locally
	if [[ $local_mode == true ]]; then
		install_py_path="$local_install_py"

		if [[ ! -f $install_py_path ]]; then
			print_error "Local install.py not found at: $install_py_path"
			exit 1
		fi
	else
		# Download install.py to temp location
		install_py_path=$(mktemp)
		trap 'rm -f "$install_py_path"' EXIT
		download_install_py "$install_py_path"
	fi

	# Run install.py with all arguments forwarded
	python3 "$install_py_path" "$@"
}

main "$@"
