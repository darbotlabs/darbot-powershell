# Example: Using Darbot.MCP with GitHub Copilot

## Overview

This example demonstrates how to use the Darbot.MCP module to expose PowerShell functionality to GitHub Copilot via the Model Context Protocol (MCP).

## Prerequisites

1. PowerShell 7.0 or later
1. Visual Studio Code with GitHub Copilot extension
1. Darbot.MCP module loaded

## Setup

```powershell
# Import the Darbot.MCP module
Import-Module /path/to/Darbot.MCP

# Check current status
Get-MCPInfo

# Start the MCP server on default port 8080
Start-MCPServer

# Or start on a specific port
Start-MCPServer -Port 8085
```

## Basic Usage

### 1. Start MCP Server

```powershell
PS> Start-MCPServer -Port 8080
Starting MCP Server on port 8080...
MCP Server started successfully on http://localhost:8080
Note: Use Stop-MCPServer to stop the server
```

### 2. Configure GitHub Copilot (VS Code)

In VS Code settings.json, add the MCP server configuration:

```json
{
  "github.copilot.chat.mcp.servers": {
    "darbot-powershell": {
      "command": "powershell",
      "args": ["-Command", "Import-Module /path/to/Darbot.MCP; Start-MCPServer -Port 8080"],
      "uri": "http://localhost:8080"
    }
  }
}
```

### 3. Using MCP with Copilot

Once configured, you can ask GitHub Copilot to use PowerShell commands:

**Example Copilot prompts:**

- "Use darbot-powershell to get the current date and time"
- "Use darbot-powershell to list the top 5 processes by CPU usage"
- "Use darbot-powershell to get system information"
- "Use darbot-powershell to check disk space on all drives"

The MCP server will execute these PowerShell commands and return the results to Copilot.

## Available MCP Tools

The Darbot.MCP server exposes the following tools to AI assistants:

### run_powershell

- **Name**: `run_powershell`
- **Description**: Execute PowerShell commands and scripts
- **Input**:
    - `command` (string): PowerShell command or script to execute

## Example MCP Protocol Messages

### List Available Tools

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/list"
}
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "tools": [
      {
        "name": "run_powershell",
        "description": "Execute PowerShell commands and scripts",
        "inputSchema": {
          "type": "object",
          "properties": {
            "command": {
              "type": "string",
              "description": "PowerShell command or script to execute"
            }
          },
          "required": ["command"]
        }
      }
    ]
  }
}
```

### Execute PowerShell Command

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "run_powershell",
    "arguments": {
      "command": "Get-Process | Select-Object -First 5 | Format-Table"
    }
  }
}
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "ProcessName     Id  CPU(s)   Path\n-----------     --  ------   ----\nApplication    1234   15.23   C:\\Program Files\\...\n..."
      }
    ]
  }
}
```

## Direct PowerShell Usage

You can also use the module functions directly in PowerShell:

```powershell
# Execute a script with timeout
$result = Invoke-MCPScript -Script "Get-Date" -TimeoutSeconds 10
if ($result.Success) {
    Write-Host $result.Output
} else {
    Write-Error $result.Error
}

# Execute commands via MCP context
Invoke-MCPCommand { Get-ComputerInfo | Select-Object WindowsProductName, TotalPhysicalMemory }

# Process individual MCP requests (for testing)
Start-MCPServer -Port 8090
# In another terminal, send HTTP requests
Invoke-MCPServerRequest -TimeoutSeconds 30
Stop-MCPServer
```

## Security Considerations

- The MCP server runs locally and only accepts connections from localhost
- PowerShell execution is subject to the current user's permissions and execution policy
- Consider running with restricted execution policies in production environments
- The server does not implement authentication - it's designed for local development use

## Troubleshooting

### Server Won't Start

```powershell
# Check if port is already in use
Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue

# Try a different port
Start-MCPServer -Port 8081
```

### Commands Timing Out

```powershell
# Increase timeout for long-running scripts
Invoke-MCPScript -Script "Some-LongRunningCommand" -TimeoutSeconds 120
```

### Stopping the Server

```powershell
# Always stop the server when done
Stop-MCPServer

# Check status
Get-MCPInfo
```

## Advanced Examples

### Custom Script Execution

```powershell
# Create a custom PowerShell script
$customScript = @"
param($ComputerName = $env:COMPUTERNAME)
Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName | 
    Select-Object Caption, Version, LastBootUpTime
"@

Invoke-MCPScript -Script $customScript
```

### System Administration Tasks

```powershell
# Example: System health check
$healthCheck = @"
$report = @{
    DateTime = Get-Date
    DiskSpace = Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace/1GB,2)}}
    Memory = Get-WmiObject -Class Win32_OperatingSystem | Select-Object @{Name="FreeGB";Expression={[math]::Round($_.FreePhysicalMemory/1MB,2)}}
    TopProcesses = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, CPU, WorkingSet
}
$report | ConvertTo-Json -Depth 3
"@

$result = Invoke-MCPScript -Script $healthCheck
Write-Host $result.Output
```

This example script provides comprehensive documentation for using the Darbot.MCP module with GitHub Copilot and other AI assistants that support the Model Context Protocol.
