@echo off
REM Quick setup script for darbot-powershell MCP connector

echo 🚀 darbot-powershell MCP Quick Setup
echo ==================================

REM Check if PowerShell is installed
pwsh --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ PowerShell 7.0+ is required but not installed.
    echo 📥 Install PowerShell from: https://github.com/PowerShell/PowerShell#get-powershell
    exit /b 1
)

echo ✅ PowerShell found: 
pwsh --version

REM Check if we're in the right directory
if not exist "package.json" (
    echo ❌ Please run this script from the darbot-powershell root directory
    exit /b 1
)

if not exist "setup-mcp.ps1" (
    echo ❌ Please run this script from the darbot-powershell root directory
    exit /b 1
)

echo 📦 Starting setup...

REM Run the PowerShell setup script
pwsh -ExecutionPolicy Bypass -File .\setup-mcp.ps1 %*