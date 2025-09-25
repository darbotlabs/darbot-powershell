# Copilot Instructions for darbot-powershell

## Project Overview

This repository is **darbot-powershell**, a Model Context Protocol (MCP) connector that enables AI assistants to execute PowerShell commands. It's a research fork that transforms PowerShell into a powerful MCP connector, allowing seamless integration with AI assistants like GitHub Copilot, Claude, and other MCP-compatible tools.

## Key Technologies & Architecture

- **PowerShell 7+**: Core runtime and scripting engine
- **Node.js**: Build tooling and package management
- **MCP (Model Context Protocol)**: AI assistant integration protocol
- **Cross-platform**: Supports Windows, Linux, and macOS
- **MSBuild & .NET**: C# components and build system

## Development Environment Setup

### Prerequisites
1. **PowerShell 7.0+** - Core runtime
2. **Node.js 16+** - Build tooling 
3. **npm 8+** - Package manager
4. **.NET SDK** - For C# components

### Quick Start
```bash
# Clone and setup
git clone https://github.com/darbotlabs/darbot-powershell.git
cd darbot-powershell

# One-click setup (Linux/macOS)
./setup.sh

# Or manual setup
npm run bootstrap  # Restore dependencies
npm run build      # Build the project
```

## Build System & Scripts

The project uses a hybrid npm/PowerShell build system:

### npm Scripts (Primary Interface)
- `npm run bootstrap` - Restore PowerShell modules and dependencies
- `npm run build` - Full project build  
- `npm run build:clean` - Clean build
- `npm run test` - Run Pester tests
- `npm run test:ci` - CI-specific test run
- `npm run lint` - PowerShell script analysis via PSScriptAnalyzer
- `npm run package` - Create distributable packages

### PowerShell Build Module
All npm scripts delegate to `build.psm1` PowerShell functions:
- `Start-PSBootstrap` - Dependency restoration
- `Start-PSBuild` - Main build process
- `Start-PSPester` - Test execution
- `Start-PSPackage` - Packaging

## File Structure & Key Directories

```
├── .github/           # GitHub workflows, templates, policies
├── src/               # Source code
│   ├── Modules/       # PowerShell modules
│   │   ├── Unix/      # Unix-specific modules (including Darbot.MCP)
│   │   ├── Windows/   # Windows-specific modules  
│   │   └── Shared/    # Cross-platform modules
│   └── [C# projects]  # .NET components
├── test/              # Test files and Pester tests
├── docs/              # Documentation
├── tools/             # Build and development tools
├── build.psm1         # Main build orchestration module
├── setup-mcp.ps1     # MCP server setup script
└── package.json       # npm configuration and scripts
```

## Coding Standards & Conventions

### PowerShell
- **Style**: OTBS (One True Brace Style) as configured in `.vscode/settings.json`
- **Formatting**: 
  - 4 spaces for indentation
  - Spaces around operators (`=`, `+`, `-`)
  - Space after separators (`,`, `;`)
  - Space before open braces and parentheses
- **Linting**: Use PSScriptAnalyzer with PSGallery settings
- **Approved Verbs**: Follow PowerShell approved verb list
- **ShouldProcess**: State-changing functions should support `-WhatIf`

### C#
- Follow .NET coding conventions
- Use EditorConfig settings (`.editorconfig`)
- StyleCop rules apply (`Settings.StyleCop`)

### General
- UTF-8 encoding with final newline
- Trim trailing whitespace
- Use semantic linefeeds in Markdown

## Testing Framework

### Pester Tests
- **Framework**: Pester PowerShell testing framework
- **Location**: `/test/` directory
- **Execution**: `npm run test` or `Invoke-Pester`
- **CI Mode**: `npm run test:ci` for continuous integration

### Test Structure
- Unit tests for individual cmdlets/functions
- Integration tests for MCP protocol functionality  
- Cross-platform compatibility tests

## Contributing Guidelines

### Making Changes
1. **Fork & Branch**: Create feature branch from `main`
2. **Environment**: Ensure PowerShell 7+ and Node.js 16+ installed
3. **Bootstrap**: Run `npm run bootstrap` to setup dependencies
4. **Develop**: Make focused, incremental changes
5. **Test**: Run `npm run test` and `npm run lint` frequently
6. **Build**: Verify `npm run build` succeeds

### Code Quality
- All PowerShell code must pass PSScriptAnalyzer linting
- Maintain existing test coverage
- Follow established patterns in similar modules
- Document public functions with comment-based help

### Pull Request Process  
1. Run full test suite: `npm run test:ci`
2. Verify clean build: `npm run build:clean`  
3. Check linting: `npm run lint`
4. Update documentation if needed
5. Reference issue number in PR description

## MCP Integration Notes

This project implements MCP (Model Context Protocol) server functionality:
- **Server Entry Point**: `src/Modules/Unix/Darbot.MCP/Darbot.MCP.psm1`
- **Configuration**: Setup via `setup-mcp.ps1`
- **Protocol**: HTTP-based communication with AI assistants
- **Commands**: PowerShell cmdlet execution through MCP interface

### Testing MCP Functionality
```powershell
# Start MCP server
Import-Module ./src/Modules/Unix/Darbot.MCP
Start-MCPServer

# Test connection
curl http://localhost:8080/health
```

## Common Issues & Solutions

### Build Failures
- **PowerShell Module Issues**: Run `npm run bootstrap` to restore
- **Permission Errors**: Ensure PowerShell execution policy allows scripts
- **Path Issues**: Use absolute paths, verify PowerShell and Node.js in PATH

### Linting Warnings
- **Invoke-Expression**: Avoid where possible, use alternatives
- **Approved Verbs**: Use standard PowerShell verbs (Get, Set, Start, Stop, etc.)
- **ShouldProcess**: Add to state-changing functions

### Cross-Platform Considerations
- Test on Windows, Linux, and macOS when possible
- Use `$IsWindows`, `$IsLinux`, `$IsMacOS` built-in variables
- Platform-specific modules in `src/Modules/Windows/` and `src/Modules/Unix/`

## Performance Considerations
- This is a PowerShell-to-MCP bridge, so minimize overhead
- Use efficient PowerShell patterns (avoid unnecessary object creation)  
- Consider async patterns for I/O operations
- Profile with PowerShell's built-in `Measure-Command`

## Documentation
- **README.md**: User-facing setup and usage
- **docs/**: Technical documentation and architecture
- **Comment-based Help**: Document all public functions
- **CHANGELOG.md**: Track version changes