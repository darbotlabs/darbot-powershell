# AI Assistant Configuration Recipes

This guide provides copy-paste configuration recipes for integrating darbot-powershell with popular AI assistants and platforms.

## 🤖 GitHub Copilot

### VS Code Configuration

**File Location**: 
- Windows: `%APPDATA%\Code\User\settings.json`
- macOS: `~/Library/Application Support/Code/User/settings.json`
- Linux: `~/.config/Code/User/settings.json`

**Configuration**:
```json
{
  "github.copilot.chat.mcp.servers": {
    "darbot-powershell": {
      "uri": "http://localhost:8080",
      "name": "PowerShell MCP Connector",
      "description": "Execute PowerShell commands and system administration tasks"
    }
  }
}
```

**Usage Examples**:
```
- "Use darbot-powershell to get system information"
- "Use darbot-powershell to list the top 10 processes by memory usage"
- "Use darbot-powershell to check disk space on all drives"
- "Use darbot-powershell to get network adapter information"
- "Use darbot-powershell to create a directory called 'test' in the current location"
```

### GitHub Codespaces

For GitHub Codespaces, add to `.vscode/settings.json` in your repository:

```json
{
  "github.copilot.chat.mcp.servers": {
    "darbot-powershell": {
      "uri": "http://localhost:8080"
    }
  }
}
```

## 🧠 Claude Desktop

### Configuration File Locations

- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`  
- **Linux**: `~/.config/claude/claude_desktop_config.json`

### Auto-Start Configuration

```json
{
  "mcp": {
    "servers": {
      "darbot-powershell": {
        "command": "powershell",
        "args": [
          "-Command",
          "cd '/path/to/darbot-powershell'; Import-Module ./src/Modules/Unix/Darbot.MCP/Darbot.MCP.psd1; Start-MCPServer -Port 8080; while($true) { Start-Sleep -Seconds 1 }"
        ],
        "env": {
          "PATH": "/usr/local/bin:/usr/bin:/bin"
        }
      }
    }
  }
}
```

### Manual Start Configuration

```json
{
  "mcp": {
    "servers": {
      "darbot-powershell": {
        "uri": "http://localhost:8080",
        "name": "PowerShell MCP Server"
      }
    }
  }
}
```

**Usage**: Start the server manually, then chat with Claude normally. Claude will automatically detect and use the MCP server.

## 🌐 Web-Based AI Tools

### OpenAI ChatGPT (via Browser Extensions)

For browser extensions that support MCP:

```javascript
// Browser extension configuration
{
  "mcp_servers": {
    "darbot-powershell": {
      "url": "http://localhost:8080",
      "name": "PowerShell Commands",
      "description": "Execute PowerShell commands"
    }
  }
}
```

### Microsoft Copilot (Web)

Configure custom actions pointing to:
- **Endpoint**: `http://localhost:8080`
- **Method**: POST
- **Content-Type**: application/json

**Request Template**:
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "run_powershell",
    "arguments": {
      "command": "{{user_command}}"
    }
  }
}
```

## 🔧 Power Platform

### Custom Connector Configuration

1. **General Information**:
   - **Name**: darbot-powershell
   - **Description**: PowerShell MCP Connector for system automation
   - **Host**: localhost:8080
   - **Base URL**: /

2. **Security**: None (for localhost development)

3. **Definition**:

**Action: Execute PowerShell Command**

- **Summary**: Execute a PowerShell command or script
- **Description**: Runs PowerShell commands through the MCP protocol
- **Operation ID**: run_powershell
- **Visibility**: important

**Request**:
- **Method**: POST
- **URL**: /
- **Body**: 
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "run_powershell",
    "arguments": {
      "command": "Get-Process"
    }
  }
}
```

**Parameters**:
- **command** (string, required): PowerShell command to execute

### Power Automate Flow

```json
{
  "definition": {
    "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
    "actions": {
      "Execute_PowerShell": {
        "type": "Http",
        "inputs": {
          "method": "POST",
          "uri": "http://localhost:8080",
          "headers": {
            "Content-Type": "application/json"
          },
          "body": {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/call",
            "params": {
              "name": "run_powershell",
              "arguments": {
                "command": "@{variables('PowerShellCommand')}"
              }
            }
          }
        }
      }
    }
  }
}
```

## 🏢 Microsoft Copilot Studio

### Bot Configuration

1. **Create New Topic**: "Execute PowerShell Command"

2. **Add HTTP Request Node**:
   - **URL**: `http://localhost:8080`
   - **Method**: POST
   - **Headers**: 
     ```
     Content-Type: application/json
     ```
   - **Body**:
     ```json
     {
       "jsonrpc": "2.0",
       "id": 1,
       "method": "tools/call",
       "params": {
         "name": "run_powershell",
         "arguments": {
           "command": "{x:command}"
         }
       }
     }
     ```

3. **Process Response**:
   - Parse JSON response
   - Extract result.content[0].text
   - Display to user

### Sample Dialog Flow

```yaml
- name: PowerShell_Command_Topic
  trigger:
    - "run powershell"
    - "execute command"
    - "powershell"
  
  actions:
    - name: Ask_For_Command
      type: question
      prompt: "What PowerShell command would you like me to execute?"
      variable: user_command
    
    - name: Execute_Command
      type: http_request
      url: "http://localhost:8080"
      method: POST
      body: |
        {
          "jsonrpc": "2.0",
          "id": 1,
          "method": "tools/call",
          "params": {
            "name": "run_powershell",
            "arguments": {
              "command": "${user_command}"
            }
          }
        }
      variable: powershell_result
    
    - name: Show_Result
      type: message
      text: "Command executed successfully: ${powershell_result.result.content[0].text}"
```

## 📱 Mobile AI Apps

### Shortcuts (iOS)

Create a Shortcut that:

1. **Get Text Input**: PowerShell command
2. **HTTP Request**:
   - URL: `http://localhost:8080`
   - Method: POST
   - Headers: `Content-Type: application/json`
   - Body:
     ```json
     {
       "jsonrpc": "2.0",
       "id": 1,
       "method": "tools/call",
       "params": {
         "name": "run_powershell",
         "arguments": {
           "command": "[Input Text]"
         }
       }
     }
     ```
3. **Show Result**: Display the response

### Tasker (Android)

```javascript
// HTTP Request Task
A1: HTTP Request [
  Method: POST
  URL: http://localhost:8080
  Headers: Content-Type: application/json
  Body: {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "run_powershell",
      "arguments": {
        "command": "%command"
      }
    }
  }
  Variable: %response
]

A2: Flash [ Text: %response ]
```

## 🔧 Custom Integrations

### Python Integration

```python
import requests
import json

class DarbotPowerShellClient:
    def __init__(self, base_url="http://localhost:8080"):
        self.base_url = base_url
    
    def run_command(self, command):
        payload = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/call",
            "params": {
                "name": "run_powershell",
                "arguments": {
                    "command": command
                }
            }
        }
        
        response = requests.post(self.base_url, json=payload)
        return response.json()

# Usage
client = DarbotPowerShellClient()
result = client.run_command("Get-Date")
print(result['result']['content'][0]['text'])
```

### Node.js Integration

```javascript
const axios = require('axios');

class DarbotPowerShellClient {
    constructor(baseUrl = 'http://localhost:8080') {
        this.baseUrl = baseUrl;
    }
    
    async runCommand(command) {
        const payload = {
            jsonrpc: '2.0',
            id: 1,
            method: 'tools/call',
            params: {
                name: 'run_powershell',
                arguments: {
                    command: command
                }
            }
        };
        
        try {
            const response = await axios.post(this.baseUrl, payload);
            return response.data;
        } catch (error) {
            throw new Error(`PowerShell execution failed: ${error.message}`);
        }
    }
}

// Usage
const client = new DarbotPowerShellClient();
client.runCommand('Get-Process | Select-Object -First 5')
    .then(result => console.log(result.result.content[0].text))
    .catch(error => console.error(error));
```

### cURL Commands

```bash
# List available tools
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'

# Execute PowerShell command
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc":"2.0",
    "id":2,
    "method":"tools/call",
    "params":{
      "name":"run_powershell",
      "arguments":{"command":"Get-ComputerInfo | Select-Object WindowsProductName"}
    }
  }'

# Execute with timeout
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc":"2.0",
    "id":3,
    "method":"tools/call",
    "params":{
      "name":"run_powershell",
      "arguments":{
        "command":"Get-Process",
        "timeout": 30
      }
    }
  }'
```

## 🚀 Production Considerations

### Reverse Proxy Configuration (nginx)

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Docker Deployment

```dockerfile
FROM mcr.microsoft.com/powershell:latest

WORKDIR /app
COPY . .

RUN pwsh -Command "Import-Module ./src/Modules/Unix/Darbot.MCP/Darbot.MCP.psd1"

EXPOSE 8080

CMD ["pwsh", "-Command", "Import-Module ./src/Modules/Unix/Darbot.MCP/Darbot.MCP.psd1; Start-MCPServer -Port 8080; while($true) { Start-Sleep -Seconds 1 }"]
```

---

**Copy and paste any of these configurations to quickly integrate darbot-powershell with your preferred AI assistant!** 🚀