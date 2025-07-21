# Integration Verification Guide

This guide helps you verify that darbot-powershell is working correctly with various AI assistants and platforms.

## 🧪 Basic Testing

### 1. MCP Server Verification

```powershell
# Start PowerShell and import the module
Import-Module ./src/Modules/Unix/Darbot.MCP/Darbot.MCP.psd1

# Check MCP info
Get-MCPInfo
# Should show: MCPServerStatus: Stopped

# Start server
Start-MCPServer -Port 8080
# Should show: MCP Server started successfully on http://localhost:8080

# Verify server status
Get-MCPInfo
# Should show: MCPServerStatus: Running, MCPServerPort: 8080

# Test command execution
Invoke-MCPScript -Script "Get-Date"
# Should return current date/time

# Test with timeout
Invoke-MCPScript -Script "Get-Process | Select-Object -First 3" -TimeoutSeconds 10
# Should return top 3 processes

# Clean up
Stop-MCPServer
```

### 2. HTTP Endpoint Testing

```bash
# Test tools list endpoint
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' \
  | jq '.'

# Expected response:
# {
#   "jsonrpc": "2.0",
#   "id": 1,
#   "result": {
#     "tools": [
#       {
#         "name": "run_powershell",
#         "description": "Execute PowerShell commands and scripts",
#         "inputSchema": {...}
#       }
#     ]
#   }
# }

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
  }' | jq '.'

# Expected response with current date/time
```

## 🤖 AI Assistant Integration Testing

### GitHub Copilot (VS Code)

1. **Setup Configuration**:
   - Copy `mcp-configs/vscode-settings.json` content to your VS Code settings
   - Restart VS Code
   - Ensure darbot-powershell MCP server is running on port 8080

2. **Test Commands**:
   - Open VS Code chat (Ctrl+Shift+I)
   - Type: "Use darbot-powershell to get system information"
   - Expected: Copilot should execute `Get-ComputerInfo` or similar command
   - Type: "Use darbot-powershell to list running processes"
   - Expected: Should show process list

3. **Verification Signs**:
   ✅ Copilot mentions using "darbot-powershell" in responses
   ✅ PowerShell commands are executed and results displayed
   ✅ No connection errors in VS Code Developer Tools (F12)

### Claude Desktop

1. **Setup Configuration**:
   - Copy `mcp-configs/claude-config.json` to Claude's config file
   - Restart Claude Desktop
   - Ensure MCP server is running

2. **Test Commands**:
   - Start new conversation
   - Ask: "Can you help me get system information using PowerShell?"
   - Ask: "Show me the current disk usage"
   - Ask: "What processes are currently running?"

3. **Verification Signs**:
   ✅ Claude automatically detects PowerShell capability
   ✅ Commands are executed without manual setup
   ✅ Results are formatted and explained

### Power Platform

1. **Custom Connector Testing**:
   - Create a test flow using the darbot-powershell connector
   - Use the template from `mcp-configs/power-platform-template.json`

2. **Test Flow**:
   ```json
   {
     "trigger": "manual",
     "actions": {
       "Execute_PowerShell": {
         "type": "Http",
         "inputs": {
           "uri": "http://localhost:8080",
           "method": "POST",
           "body": {
             "jsonrpc": "2.0",
             "id": 1,
             "method": "tools/call",
             "params": {
               "name": "run_powershell",
               "arguments": {
                 "command": "Get-Date"
               }
             }
           }
         }
       }
     }
   }
   ```

3. **Verification Signs**:
   ✅ HTTP connector returns 200 status
   ✅ Response contains PowerShell command output
   ✅ Flow runs without errors

### Copilot Studio

1. **Bot Testing**:
   - Create a test bot with PowerShell integration
   - Add HTTP request action pointing to `http://localhost:8080`

2. **Test Conversation**:
   - User: "Get system information"
   - Bot should trigger PowerShell command
   - Response should contain system details

3. **Verification Signs**:
   ✅ Bot successfully calls MCP endpoint
   ✅ PowerShell commands execute correctly
   ✅ Users receive formatted responses

## 🔧 Troubleshooting Common Issues

### Server Won't Start

**Issue**: `Start-MCPServer` fails
```powershell
# Check if port is in use
Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue

# Try different port
Start-MCPServer -Port 8081

# Check PowerShell execution policy
Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### AI Assistant Can't Connect

**Issue**: AI assistant shows connection errors

1. **Verify server is running**:
   ```powershell
   Get-MCPInfo
   # Should show: MCPServerStatus: Running
   ```

2. **Test HTTP endpoint manually**:
   ```bash
   curl -I http://localhost:8080
   # Should return HTTP/1.1 200 OK
   ```

3. **Check firewall settings**:
   - Ensure localhost traffic is allowed
   - Temporarily disable firewall to test

### Command Execution Fails

**Issue**: Commands return errors or timeout

1. **Test locally first**:
   ```powershell
   Invoke-MCPScript -Script "Get-Date" -TimeoutSeconds 30
   ```

2. **Check execution policy**:
   ```powershell
   Get-ExecutionPolicy -List
   ```

3. **Enable verbose logging**:
   ```powershell
   $VerbosePreference = "Continue"
   Start-MCPServer -Verbose
   ```

### Permission Errors

**Issue**: Access denied when running commands

1. **Run as appropriate user**:
   - Ensure PowerShell has necessary permissions
   - Consider running as administrator for system commands

2. **Check user context**:
   ```powershell
   whoami
   # Verify you're running as expected user
   ```

## 📊 Performance Testing

### Load Testing

```powershell
# Test multiple concurrent requests
$jobs = 1..10 | ForEach-Object {
    Start-Job -ScriptBlock {
        Invoke-RestMethod -Uri "http://localhost:8080" -Method POST -ContentType "application/json" -Body '{
            "jsonrpc":"2.0",
            "id":1,
            "method":"tools/call",
            "params":{
                "name":"run_powershell",
                "arguments":{"command":"Get-Date"}
            }
        }'
    }
}

# Wait for all jobs and collect results
$results = $jobs | Wait-Job | Receive-Job
$jobs | Remove-Job

Write-Host "Completed $($results.Count) requests successfully"
```

### Response Time Testing

```powershell
# Measure response times
$times = 1..5 | ForEach-Object {
    $start = Get-Date
    Invoke-MCPScript -Script "Get-Date"
    $end = Get-Date
    ($end - $start).TotalMilliseconds
}

$average = ($times | Measure-Object -Average).Average
Write-Host "Average response time: $average ms"
```

## ✅ Success Checklist

- [ ] MCP server starts without errors
- [ ] HTTP endpoints respond correctly
- [ ] GitHub Copilot can execute PowerShell commands
- [ ] Claude Desktop integrates seamlessly
- [ ] Power Platform connector works
- [ ] Copilot Studio bot responds correctly
- [ ] Custom integrations via HTTP work
- [ ] Performance meets expectations
- [ ] Error handling works properly
- [ ] Security policies are enforced

## 📈 Next Steps

Once verification is complete:

1. **Production Deployment**: Consider security hardening for production use
2. **Monitoring**: Implement logging and monitoring for production environments  
3. **Custom Commands**: Extend with organization-specific PowerShell modules
4. **Documentation**: Create internal documentation for your team
5. **Training**: Train users on effective AI assistant integration

---

**🎉 Congratulations!** Your darbot-powershell MCP connector is fully operational and ready for AI-powered automation!