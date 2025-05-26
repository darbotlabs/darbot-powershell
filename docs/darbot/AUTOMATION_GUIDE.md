# 🚀 Darbot PowerShell Automation Guide

Welcome to the automated PowerShell development environment! This guide explains how to use all the automation features we've set up.

## 🛠️ Quick Start

### Prerequisites
- PowerShell 7.0+ (`pwsh -v`)
- Node.js 16+ (`node --version`)
- npm 8+ (`npm --version`)

### Bootstrap the Environment
```bash
# Using npm script (recommended)
npm run bootstrap

# Or directly with PowerShell
pwsh -Command "Import-Module './build.psm1'; Start-PSBootstrap"
```

## 📦 Available npm Scripts

All PowerShell build tasks are now accessible via npm for consistency:

```bash
# Bootstrap dependencies
npm run bootstrap

# Clean build
npm run build:clean

# Regular build  
npm run build

# Package PowerShell
npm run package

# Run all tests
npm run test

# Run tests in CI mode
npm run test:ci

# Lint code with PSScriptAnalyzer
npm run lint

# Pre-packaging (builds automatically)
npm run prepack
```

## 🤖 Automated Dependency Management

### Dependabot Configuration
Dependabot automatically monitors and creates PRs for:
- **GitHub Actions** (daily updates)
- **Docker images** (daily updates)  
- **NuGet packages** (weekly on Mondays)
- **npm packages** (weekly on Mondays)

All dependency PRs are labeled with `CL-BuildPackaging` for easy filtering.

### Manual Dependency Updates
```bash
# Update npm dependencies
npm update

# Update PowerShell modules (handled by bootstrap)
npm run bootstrap
```

## 🚀 Continuous Integration

### GitHub Actions Workflows

#### PowerShell CI (`powershell-ci.yml`)
- **Triggers**: Push to master/main/develop, PRs
- **Matrix**: Windows, macOS, Linux
- **Steps**:
  1. Bootstrap environment
  2. Build PowerShell
  3. Run Pester tests
  4. PSScriptAnalyzer linting
  5. Package creation (Linux only)
  6. Artifact upload

#### Code Coverage (`powershell-ci.yml` - separate job)
- **Triggers**: Pull requests only
- **Steps**:
  1. Run tests with coverage
  2. Upload to Codecov

### VS Code Tasks
Access build tasks directly in VS Code:
- `Ctrl+Shift+P` → "Tasks: Run Task"
- Available tasks:
  - **Bootstrap**: Restore dependencies
  - **Build**: Standard build
  - **Clean Build**: Clean and build

## 🧪 Testing & Quality

### Running Tests Locally
```bash
# Quick test run
npm run test

# CI-style tests with detailed output
npm run test:ci

# Manual Pester execution
pwsh -Command "Invoke-Pester -CI"
```

### Code Quality Checks
```bash
# Run PSScriptAnalyzer
npm run lint

# Manual analysis with custom settings
pwsh -Command "Invoke-ScriptAnalyzer -Path . -Recurse -Settings PSGallery"
```

### Pre-commit Checklist
Before submitting a PR, ensure:
- [ ] `npm run build` succeeds
- [ ] `npm run test` passes
- [ ] `npm run lint` shows no issues
- [ ] Code coverage hasn't decreased

## 📋 Issue & PR Templates

### Issue Templates
- **Bug Report Enhanced**: Structured bug reporting with environment details
- **Feature Request Enhanced**: Feature suggestions with priority levels
- **Microsoft Update Issue**: Existing template for update-related issues

### Pull Request Template
Enhanced template includes:
- Basic requirements checklist
- Quality assurance steps
- Automated testing verification
- Breaking change documentation

## 🔒 Security & Best Practices

### Branch Protection (Recommended)
Enable these settings in GitHub repository settings:
- Require status checks before merging
- Require CI workflows to pass
- Require up-to-date branches before merging
- Require linear history

### Secret Scanning
The repository should have:
- Secret scanning enabled
- Dependency review enabled
- Security advisories configured

## 🎯 Development Workflow

### Standard Development Cycle
1. **Create feature branch**: `git checkout -b feature/my-feature`
2. **Bootstrap**: `npm run bootstrap` (first time)
3. **Develop**: Make your changes
4. **Test locally**: `npm run test && npm run lint`
5. **Build**: `npm run build`
6. **Commit**: Follow conventional commit format
7. **Push**: `git push origin feature/my-feature`
8. **Create PR**: Use the enhanced PR template
9. **CI validation**: Wait for all checks to pass
10. **Review & merge**: After approval

### Release Process
```bash
# Package for release
npm run package

# The build system handles versioning and packaging
# Artifacts are uploaded automatically by CI
```

## 🔧 Troubleshooting

### Common Issues

#### Bootstrap Fails
```bash
# Clear module cache and retry
Remove-Module * -Force
npm run bootstrap
```

#### Build Errors
```bash
# Clean build
npm run build:clean

# Check .NET version
dotnet --version
```

#### Test Failures
```bash
# Run specific test
pwsh -Command "Invoke-Pester -Path 'path/to/test.ps1'"

# Verbose test output
pwsh -Command "Invoke-Pester -Verbose"
```

### Getting Help
- Check existing issues in GitHub
- Use GitHub Discussions for questions
- Follow the issue templates for bug reports

## 🎮 Quest Complete! 

You now have a fully automated PowerShell development environment with:
- ✅ Automated dependency management
- ✅ Cross-platform CI/CD
- ✅ Code quality enforcement  
- ✅ Automated packaging
- ✅ Enhanced issue/PR templates
- ✅ Comprehensive documentation

Happy coding! 🚀
