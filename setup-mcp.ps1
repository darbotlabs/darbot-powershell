#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick setup script for darbot-powershell MCP connector
    
.DESCRIPTION
    This script automates the setup process for darbot-powershell, making it easy to:
    - Build the project
    - Import the MCP module
    - Start the MCP server
    - Generate configuration files for popular AI assistants
    
.PARAMETER Port
    Port to run the MCP server on (default: 8080)
    
.PARAMETER ConfigOnly
    Only generate configuration files without starting server
    
.PARAMETER InstallPath
    Custom installation path for configuration files
    
.EXAMPLE
    ./setup-mcp.ps1
    Standard setup with MCP server on port 8080
    
.EXAMPLE
    ./setup-mcp.ps1 -Port 9090 -ConfigOnly
    Generate configs for port 9090 without starting server
#>

param(
    [int]$Port = 8080,
    [switch]$ConfigOnly,
    [string]$InstallPath = $null
)

$ErrorActionPreference = "Stop"

# Colors for output
$Green = if ($PSVersionTable.Platform -eq "Win32NT") { "Green" } else { "`e[32m" }
$Yellow = if ($PSVersionTable.Platform -eq "Win32NT") { "Yellow" } else { "`e[33m" }
$Red = if ($PSVersionTable.Platform -eq "Win32NT") { "Red" } else { "`e[31m" }
$Reset = if ($PSVersionTable.Platform -eq "Win32NT") { "" } else { "`e[0m" }

function Write-ColorOutput {
    param($Message, $Color)
    if ($PSVersionTable.Platform -eq "Win32NT") {
        Write-Host $Message -ForegroundColor $Color
    } else {
        Write-Host "$Color$Message$Reset"
    }
}

function Test-Prerequisites {
    Write-ColorOutput "🔍 Checking prerequisites..." $Yellow
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-ColorOutput "❌ PowerShell 7.0+ required. Current version: $($PSVersionTable.PSVersion)" $Red
        exit 1
    }
    Write-ColorOutput "✅ PowerShell version: $($PSVersionTable.PSVersion)" $Green
    
    # Check if npm is available
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "⚠️  npm not found. You may need to run 'npm run bootstrap' manually." $Yellow
    } else {
        Write-ColorOutput "✅ npm available" $Green
    }
}

function Build-Project {
    Write-ColorOutput "🏗️  Building darbot-powershell..." $Yellow
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        try {
            npm run bootstrap 2>&1 | Out-Null
            npm run build 2>&1 | Out-Null
            Write-ColorOutput "✅ Project built successfully" $Green
        } catch {
            Write-ColorOutput "⚠️  Build failed. Continuing anyway..." $Yellow
        }
    }
}

function Import-MCPModule {
    Write-ColorOutput "📦 Importing MCP module..." $Yellow
    
    $modulePath = if ($IsWindows -or $PSVersionTable.Platform -eq "Win32NT") {
        "./src/Modules/Windows/Darbot.MCP/Darbot.MCP.psd1"
    } else {
        "./src/Modules/Unix/Darbot.MCP/Darbot.MCP.psd1"
    }
    
    if (Test-Path $modulePath) {
        Import-Module $modulePath -Force
        Write-ColorOutput "✅ MCP module imported successfully" $Green
        return $true
    } else {
        Write-ColorOutput "❌ MCP module not found at $modulePath" $Red
        return $false
    }
}

function Start-MCPServerBackground {
    param([int]$ServerPort)
    
    Write-ColorOutput "🚀 Starting MCP server on port $ServerPort..." $Yellow
    
    try {
        Start-MCPServer -Port $ServerPort
        Write-ColorOutput "✅ MCP server started on http://localhost:$ServerPort" $Green
        return $true
    } catch {
        Write-ColorOutput "❌ Failed to start MCP server: $($_.Exception.Message)" $Red
        return $false
    }
}

function Generate-ConfigFiles {
    param([int]$ServerPort)
    
    Write-ColorOutput "⚙️  Generating AI assistant configuration files..." $Yellow
    
    $configDir = Join-Path $PWD "mcp-configs"
    New-Item -ItemType Directory -Force -Path $configDir | Out-Null
    
    # GitHub Copilot VS Code config
    $vscodeConfig = @{
        "github.copilot.chat.mcp.servers" = @{
            "darbot-powershell" = @{
                uri = "http://localhost:$ServerPort"
                name = "PowerShell MCP Connector"
                description = "Execute PowerShell commands via MCP"
            }
        }
    }
    $vscodeConfig | ConvertTo-Json -Depth 3 | Set-Content (Join-Path $configDir "vscode-settings.json")
    
    # Claude Desktop config
    $claudeConfig = @{
        mcp = @{
            servers = @{
                "darbot-powershell" = @{
                    uri = "http://localhost:$ServerPort"
                    name = "PowerShell MCP Server"
                }
            }
        }
    }
    $claudeConfig | ConvertTo-Json -Depth 3 | Set-Content (Join-Path $configDir "claude-config.json")
    
    # Power Platform HTTP request template
    $powerPlatformTemplate = @{
        jsonrpc = "2.0"
        id = 1
        method = "tools/call"
        params = @{
            name = "run_powershell"
            arguments = @{
                command = "{{PowerShellCommand}}"
            }
        }
    }
    $powerPlatformTemplate | ConvertTo-Json -Depth 3 | Set-Content (Join-Path $configDir "power-platform-template.json")
    
    # Generate README for configs
    $configReadme = @"
# darbot-powershell Configuration Files

This directory contains ready-to-use configuration files for various AI assistants.

## VS Code (GitHub Copilot)

Add the contents of ``vscode-settings.json`` to your VS Code settings:
- Windows: ``%APPDATA%\Code\User\settings.json``
- macOS: ``~/Library/Application Support/Code/User/settings.json``
- Linux: ``~/.config/Code/User/settings.json``

## Claude Desktop

Copy ``claude-config.json`` contents to your Claude configuration:
- Windows: ``%APPDATA%\Claude\claude_desktop_config.json``
- macOS: ``~/Library/Application Support/Claude/claude_desktop_config.json``
- Linux: ``~/.config/claude/claude_desktop_config.json``

## Power Platform

Use ``power-platform-template.json`` as the HTTP request body template in Power Automate flows.

## Server URL

All configurations point to: http://localhost:$ServerPort
"@
    
    $configReadme | Set-Content (Join-Path $configDir "README.md")
    
    Write-ColorOutput "✅ Configuration files generated in: $configDir" $Green
    Write-ColorOutput "📖 See $configDir/README.md for usage instructions" $Green
}

function Show-Usage {
    Write-ColorOutput "`n🎉 Setup complete! Your darbot-powershell MCP connector is ready." $Green
    Write-ColorOutput "`n📝 Next Steps:" $Yellow
    Write-ColorOutput "1. Configure your AI assistant using files in ./mcp-configs/" $Green
    Write-ColorOutput "2. Try these example commands in your AI assistant:" $Green
    Write-ColorOutput "   - 'Use darbot-powershell to get system information'" $Green
    Write-ColorOutput "   - 'Use darbot-powershell to list running processes'" $Green
    Write-ColorOutput "   - 'Use darbot-powershell to check disk space'" $Green
    Write-ColorOutput "`n🔧 Server Management:" $Yellow
    Write-ColorOutput "- Check status: Get-MCPInfo" $Green
    Write-ColorOutput "- Stop server: Stop-MCPServer" $Green
    Write-ColorOutput "- View logs: Get-MCPServerLogs (if available)" $Green
    Write-ColorOutput "`n📖 Documentation:" $Yellow
    Write-ColorOutput "- Installation Guide: ./INSTALL.md" $Green
    Write-ColorOutput "- AI Integration Guide: ./docs/AI_INTEGRATION_GUIDE.md" $Green
    Write-ColorOutput "- Usage Examples: ./Examples/MCP-Usage.md" $Green
}

# Main execution
Write-ColorOutput "🚀 darbot-powershell MCP Setup" $Green
Write-ColorOutput "=" * 50 $Green

Test-Prerequisites

if (-not $ConfigOnly) {
    Build-Project
    
    if (Import-MCPModule) {
        if (Start-MCPServerBackground -ServerPort $Port) {
            Generate-ConfigFiles -ServerPort $Port
            Show-Usage
            
            Write-ColorOutput "`n⏸️  Press Ctrl+C to stop the MCP server" $Yellow
            try {
                while ($true) {
                    Start-Sleep -Seconds 1
                }
            } catch {
                Write-ColorOutput "`n🛑 Shutting down MCP server..." $Yellow
                Stop-MCPServer
                Write-ColorOutput "✅ MCP server stopped" $Green
            }
        }
    }
} else {
    Generate-ConfigFiles -ServerPort $Port
    Write-ColorOutput "✅ Configuration files generated only" $Green
}