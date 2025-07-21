#!/bin/bash
# Quick setup script for darbot-powershell MCP connector

set -e

echo "🚀 darbot-powershell MCP Quick Setup"
echo "=================================="

# Check if PowerShell is installed
if ! command -v pwsh &> /dev/null; then
    echo "❌ PowerShell 7.0+ is required but not installed."
    echo "📥 Install PowerShell from: https://github.com/PowerShell/PowerShell#get-powershell"
    exit 1
fi

echo "✅ PowerShell found: $(pwsh --version)"

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -f "setup-mcp.ps1" ]; then
    echo "❌ Please run this script from the darbot-powershell root directory"
    exit 1
fi

echo "📦 Starting setup..."

# Run the PowerShell setup script
pwsh -ExecutionPolicy Bypass -File ./setup-mcp.ps1 "$@"