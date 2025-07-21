# ![logo][] darbot-powershell

Welcome to darbot-powershell - A Model Context Protocol (MCP) connector that enables AI assistants to execute PowerShell commands!

**darbot-powershell** is a research fork that transforms PowerShell into a powerful MCP connector, allowing seamless integration with AI assistants like GitHub Copilot, Claude, and other MCP-compatible tools. This enables natural language control over PowerShell automation and system administration tasks.

[logo]: assets/ps_black_64.svg?sanitize=true

## 🚀 Quick Start

### Installation & Setup

1. **Clone and Build**:
```bash
git clone https://github.com/darbotlabs/darbot-powershell.git
cd darbot-powershell
npm run bootstrap
npm run build
```

2. **Start MCP Server**:
```powershell
# Import the MCP module
Import-Module Darbot.MCP

# Start MCP server (default port 8080)
Start-MCPServer

# Check status
Get-MCPInfo
# Output: MCPServerStatus: Running, MCPServerPort: 8080
```

3. **Connect to AI Assistants** - See configuration examples below.

## 🤖 AI Assistant Integration

### GitHub Copilot (VS Code)

Add to your VS Code `settings.json`:

```json
{
  "github.copilot.chat.mcp.servers": {
    "darbot-powershell": {
      "uri": "http://localhost:8080"
    }
  }
}
```

**Usage Examples:**
- *"Use darbot-powershell to get system information"*
- *"Use darbot-powershell to list top 5 processes by CPU usage"*  
- *"Use darbot-powershell to check disk space"*

### Claude Desktop

Add to Claude's MCP configuration:

```json
{
  "mcp": {
    "servers": {
      "darbot-powershell": {
        "command": "powershell",
        "args": ["-Command", "Import-Module Darbot.MCP; Start-MCPServer -Port 8080"]
      }
    }
  }
}
```

### Power Platform & Copilot Studio

Configure as a custom connector:
1. Create new custom connector in Power Platform
2. Set endpoint URL: `http://localhost:8080` (or your server URL)
3. Configure MCP protocol for actions
4. Use in Power Apps and Copilot Studio flows

## 🔧 Available MCP Commands

| Command | Description |
|---------|-------------|
| `Start-MCPServer` | Start MCP server on specified port |
| `Stop-MCPServer` | Stop running MCP server |
| `Get-MCPInfo` | Show server status and system information |
| `Invoke-MCPScript` | Execute PowerShell with timeout/error handling |
| `Invoke-MCPServerRequest` | Process MCP requests (for testing) |

## 📖 Documentation & Examples

- **[Complete MCP Usage Guide](Examples/MCP-Usage.md)** - Detailed examples and configuration
- **[MCP Project Plan](MCP_NLWeb_Project_Plan.md)** - Development roadmap and technical details
- **[Automation Guide](docs/darbot/AUTOMATION_GUIDE.md)** - Development workflows

## 🌟 Key Features

- **🌐 HTTP MCP Server**: Local server implementing MCP JSON-RPC 2.0 protocol
- **🔧 PowerShell Execution**: Run PowerShell commands remotely via AI assistants  
- **🛡️ Security**: Localhost-only connections, respects PowerShell execution policies
- **📊 Structured Responses**: JSON-formatted output with error handling
- **⚡ Real-time Processing**: Asynchronous request handling with timeout support
- **🤝 Multi-Platform**: Windows, macOS, and Linux support

### Build status of nightly builds

| Azure CI (Windows)                       | Azure CI (Linux)                               | Azure CI (macOS)                               | CodeFactor Grade         |
|:-----------------------------------------|:-----------------------------------------------|:-----------------------------------------------|:-------------------------|
| [![windows-nightly-image][]][windows-nightly-site] | [![linux-nightly-image][]][linux-nightly-site] | [![macOS-nightly-image][]][macos-nightly-site] | [![cf-image][]][cf-site] |

[windows-nightly-site]: https://powershell.visualstudio.com/PowerShell/_build?definitionId=32
[linux-nightly-site]: https://powershell.visualstudio.com/PowerShell/_build?definitionId=23
[macos-nightly-site]: https://powershell.visualstudio.com/PowerShell/_build?definitionId=24
[windows-nightly-image]: https://powershell.visualstudio.com/PowerShell/_apis/build/status/PowerShell-CI-Windows-daily
[linux-nightly-image]: https://powershell.visualstudio.com/PowerShell/_apis/build/status/PowerShell-CI-linux-daily?branchName=master
[macOS-nightly-image]: https://powershell.visualstudio.com/PowerShell/_apis/build/status/PowerShell-CI-macos-daily?branchName=master
[cf-site]: https://www.codefactor.io/repository/github/powershell/powershell
[cf-image]: https://www.codefactor.io/repository/github/powershell/powershell/badge

## 🔧 Development & Build Commands

This repository includes comprehensive automation for development workflows:

### Quick Start Commands

```bash
# Bootstrap the environment
npm run bootstrap

# Build darbot-powershell
npm run build

# Run tests
npm run test

# Lint code
npm run lint
```

### Features

- **Cross-platform CI/CD** with GitHub Actions
- **Automated dependency management** via Dependabot
- **Code quality enforcement** with PSScriptAnalyzer
- **npm scripts** for consistent build commands
- **Enhanced issue/PR templates** for better collaboration

## 🤖 Example MCP Protocol Messages

### Tools List Request:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/list"
}
```

### PowerShell Execution Request:

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "run_powershell",
    "arguments": {
      "command": "Get-Date"
    }
  }
}
```

## 🛡️ Security Considerations

- MCP server runs locally and only accepts localhost connections
- PowerShell execution respects current user permissions and execution policies
- No authentication required - designed for local development use
- Consider restricted execution policies in production environments

## 🏗️ Building darbot-powershell

| Linux                    | Windows                    | macOS                   |
|--------------------------|----------------------------|------------------------|
| [Instructions][bd-linux] | [Instructions][bd-windows] | [Instructions][bd-macOS] |

If you have any problems building, please check the developer [FAQ].

[bd-linux]: docs/building/linux.md
[bd-windows]: docs/building/windows-core.md
[bd-macOS]: docs/building/macos.md
[FAQ]: docs/FAQ.md

## 📥 Getting the Source Code

You can clone the repository:

```sh
git clone https://github.com/darbotlabs/darbot-powershell.git
```

For more information, see [working with the darbot-powershell repository](https://github.com/darbotlabs/darbot-powershell/tree/master/docs/git).

## 💡 Contributing & Support

Want to contribute to darbot-powershell? Please start with the [Contribution Guide][] to learn how to develop and contribute.

For support, see the [Support Section][].

[Contribution Guide]: .github/CONTRIBUTING.md
[Support Section]: https://github.com/darbotlabs/darbot-powershell/tree/master/.github/SUPPORT.md

## 📄 Legal and Licensing

darbot-powershell is licensed under the [MIT license][].

[MIT license]: https://github.com/darbotlabs/darbot-powershell/tree/master/LICENSE.txt

## 🏛️ Governance

The governance policy for the darbot-powershell project follows the original [PowerShell Governance][gov] model with adaptations for the research fork.

[gov]: https://github.com/PowerShell/PowerShell/blob/master/docs/community/governance.md

## [Code of Conduct](CODE_OF_CONDUCT.md)

Please see our [Code of Conduct](CODE_OF_CONDUCT.md) before participating in this project.

## [Security Policy](.github/SECURITY.md)

For any security issues, please see our [Security Policy](.github/SECURITY.md).

---

**darbot-powershell** - Empowering AI assistants with full PowerShell capabilities through the Model Context Protocol. 🚀🤖
