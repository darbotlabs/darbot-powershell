# darbot-powershell Installation Guide

## 🚀 Quick Setup for AI Assistants

**darbot-powershell** provides a Model Context Protocol (MCP) connector that enables AI assistants to execute PowerShell commands. Follow these steps to get started quickly:

## Prerequisites

- **PowerShell 7.0+** (Core) installed on your system
- **Node.js 16.0+** and **npm 8.0+** for building
- **Git** for cloning the repository

## Installation Methods

### Method 1: From Source (Recommended)

1. **Clone and Build**:
```bash
git clone https://github.com/darbotlabs/darbot-powershell.git
cd darbot-powershell
npm run bootstrap
npm run build
```

2. **Import the MCP Module**:

**Linux/macOS:**
```powershell
Import-Module ./src/Modules/Unix/Darbot.MCP/Darbot.MCP.psd1
```

**Windows:**
```powershell
Import-Module ./src/Modules/Windows/Darbot.MCP/Darbot.MCP.psd1
```

3. **Start MCP Server**:
```powershell
Start-MCPServer
# Server starts on http://localhost:8080
```

### Method 2: Direct Module Installation

If you already have PowerShell 7+ installed, you can install just the MCP module:

```powershell
# Download the module files to your PowerShell modules directory
$modulePath = "$HOME/.local/share/powershell/Modules/Darbot.MCP"
New-Item -ItemType Directory -Force -Path $modulePath
# Copy the Darbot.MCP files to this location
```

## AI Assistant Configuration

### 🤖 GitHub Copilot (VS Code)

1. **Install VS Code Extensions**:
   - GitHub Copilot
   - GitHub Copilot Chat

2. **Configure MCP Server**:

Add to your VS Code `settings.json` (Ctrl/Cmd+Shift+P → "Preferences: Open Settings (JSON)"):

```json
{
  "github.copilot.chat.mcp.servers": {
    "darbot-powershell": {
      "uri": "http://localhost:8080",
      "name": "PowerShell MCP Connector",
      "description": "Execute PowerShell commands via MCP"
    }
  }
}
```

3. **Usage Examples**:
   - "Use darbot-powershell to get system information"
   - "Use darbot-powershell to list running processes"
   - "Use darbot-powershell to check disk space"

### 🧠 Claude Desktop

1. **Find Claude Configuration**:
   - **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
   - **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - **Linux**: `~/.config/claude/claude_desktop_config.json`

2. **Add MCP Configuration**:

```json
{
  "mcp": {
    "servers": {
      "darbot-powershell": {
        "command": "powershell",
        "args": [
          "-Command",
          "cd '/path/to/darbot-powershell'; Import-Module ./src/Modules/Unix/Darbot.MCP/Darbot.MCP.psd1; Start-MCPServer -Port 8080"
        ]
      }
    }
  }
}
```

3. **Usage**: Simply mention "Use PowerShell to..." in your Claude conversations.

### 🔧 Power Platform & Copilot Studio

#### Option 1: Custom Connector

1. **Create Custom Connector**:
   - Go to [Power Platform](https://make.powerapps.com)
   - Navigate to Data → Custom connectors
   - Click "New custom connector" → "Create from blank"

2. **Configure General Info**:
   - **Name**: darbot-powershell
   - **Description**: PowerShell MCP Connector
   - **Host**: localhost:8080 (or your server URL)
   - **Base URL**: /

3. **Define Actions**:
   - **Action Name**: run_powershell
   - **Summary**: Execute PowerShell Command
   - **Operation ID**: run_powershell
   - **Verb**: POST
   - **URL**: /mcp/tools/call

4. **Request Body Schema**:
```json
{
  "type": "object",
  "properties": {
    "jsonrpc": { "type": "string", "default": "2.0" },
    "id": { "type": "integer", "default": 1 },
    "method": { "type": "string", "default": "tools/call" },
    "params": {
      "type": "object",
      "properties": {
        "name": { "type": "string", "default": "run_powershell" },
        "arguments": {
          "type": "object",
          "properties": {
            "command": { "type": "string" }
          }
        }
      }
    }
  }
}
```

#### Option 2: HTTP Connector

Use the built-in HTTP connector to call the MCP endpoints directly:

```
POST http://localhost:8080/
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "run_powershell",
    "arguments": {
      "command": "Get-Process | Select-Object -First 5"
    }
  }
}
```

### 🔗 Other MCP-Compatible Tools

For any MCP-compatible tool, use these connection details:

- **Protocol**: HTTP
- **URL**: `http://localhost:8080`
- **Method**: JSON-RPC 2.0
- **Available Tools**: `run_powershell`

## Verification & Testing

### Test MCP Server

```powershell
# Start the server
Start-MCPServer -Port 8080

# Check status
Get-MCPInfo

# Test a command
Invoke-MCPScript -Script "Get-Date"

# Stop the server
Stop-MCPServer
```

### Test HTTP Endpoints

```bash
# Test tools list
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'

# Test command execution
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc":"2.0",
    "id":2,
    "method":"tools/call",
    "params":{
      "name":"run_powershell",
      "arguments":{"command":"Get-Date"}
    }
  }'
```

## Troubleshooting

### Common Issues

1. **Port Already in Use**:
```powershell
# Try a different port
Start-MCPServer -Port 8081
```

2. **Module Import Errors**:
```powershell
# Check PowerShell version
$PSVersionTable.PSVersion
# Should be 7.0+

# Check execution policy
Get-ExecutionPolicy
# Should allow script execution
```

3. **Connection Refused**:
   - Ensure the MCP server is running
   - Check firewall settings
   - Verify localhost connectivity

4. **Permission Errors**:
```powershell
# Set execution policy (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Debug Mode

Enable detailed logging:

```powershell
$VerbosePreference = "Continue"
Start-MCPServer -Port 8080 -Verbose
```

## Advanced Configuration

### Custom Port Configuration

```powershell
# Start on custom port
Start-MCPServer -Port 9090

# Update AI assistant configurations accordingly
```

### Security Considerations

- Server only accepts localhost connections by default
- Consider using authentication for production deployments
- Run with restricted PowerShell execution policies when possible
- Monitor command execution logs

### Production Deployment

For production environments:

1. **Use a reverse proxy** (nginx, IIS) for HTTPS
2. **Implement authentication** if exposing beyond localhost
3. **Set restrictive execution policies**
4. **Monitor and log all command executions**
5. **Use dedicated service accounts** with minimal privileges

## Support & Community

- **Documentation**: [README.md](README.md)
- **Examples**: [Examples/MCP-Usage.md](Examples/MCP-Usage.md)
- **Issues**: [GitHub Issues](https://github.com/darbotlabs/darbot-powershell/issues)
- **Discussions**: [GitHub Discussions](https://github.com/darbotlabs/darbot-powershell/discussions)

---

**Ready to go!** 🎉 Your AI assistants can now execute PowerShell commands through the darbot-powershell MCP connector.