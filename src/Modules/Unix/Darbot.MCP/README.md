# Darbot.MCP Module

## Overview

The Darbot.MCP module implements Model Context Protocol (MCP) server functionality for PowerShell, enabling AI assistants like GitHub Copilot to execute PowerShell commands and scripts remotely.

## Features

- **MCP Server**: HTTP server implementing the Model Context Protocol JSON-RPC 2.0 specification
- **PowerShell Integration**: Execute PowerShell commands and scripts via MCP protocol
- **Cross-Platform**: Works on Windows, Linux, and macOS with PowerShell Core
- **GitHub Copilot Compatible**: Designed to work with VS Code and GitHub Copilot
- **Secure**: Localhost-only connections with PowerShell execution policy enforcement

## Installation

The module is included with Darbot PowerShell. To use it:

```powershell
# Import the module (Unix/Linux/macOS)
Import-Module ./src/Modules/Unix/Darbot.MCP/Darbot.MCP.psm1

# Import the module (Windows)
Import-Module ./src/Modules/Windows/Darbot.MCP/Darbot.MCP.psm1
```

## Quick Start

```powershell
# Start MCP server
Start-MCPServer -Port 8080

# Check server status
Get-MCPInfo

# Execute a PowerShell script via MCP
Invoke-MCPScript -Script "Get-Process | Select-Object -First 5"

# Stop the server
Stop-MCPServer
```

## Functions

### Get-MCPInfo

Returns information about the current MCP environment and server status.

### Start-MCPServer

Starts an HTTP server that implements the Model Context Protocol.

**Parameters:**

- `Port` (optional): Port number (default: 8080)
- `AllowedOrigins` (optional): CORS allowed origins (default: "*")

### Stop-MCPServer

Stops the running MCP server and cleans up resources.

### Invoke-MCPCommand

Executes a PowerShell script block in the MCP context.

**Parameters:**

- `ScriptBlock`: The PowerShell script block to execute

### Invoke-MCPScript

Executes a PowerShell script with timeout support and structured error handling.

**Parameters:**

- `Script`: PowerShell command or script to execute
- `TimeoutSeconds` (optional): Execution timeout (default: 30 seconds)

### Invoke-MCPServerRequest

Processes a single MCP server request (primarily for testing).

**Parameters:**

- `TimeoutSeconds` (optional): Request timeout (default: 10 seconds)

## MCP Protocol Support

The server implements the following MCP methods:

- `tools/list`: Returns available PowerShell tools
- `tools/call`: Executes PowerShell commands via the `run_powershell` tool

## GitHub Copilot Integration

See [Examples/MCP-Usage.md](../Examples/MCP-Usage.md) for detailed instructions on configuring GitHub Copilot to use the MCP server.

## Security Notes

- Server only accepts connections from localhost
- PowerShell execution subject to current user permissions and execution policy
- No authentication implemented - designed for local development use
- Consider restricted execution policies in production environments

## Examples

```powershell
# Basic server operation
Start-MCPServer
$info = Get-MCPInfo
Write-Host "Server running on port $($info.MCPServerPort)"

# Execute system commands
$result = Invoke-MCPScript -Script "Get-ComputerInfo | Select-Object WindowsProductName"
if ($result.Success) {
    Write-Host $result.Output
}

# Clean up
Stop-MCPServer
```

## Testing

Run the test suite:

```powershell
Invoke-Pester ./test/powershell/Modules/Darbot.MCP/Darbot.MCP.Tests.ps1
```

## Version History

- **0.2.0**: Full MCP protocol implementation with HTTP server
- **0.1.0**: Initial basic implementation
