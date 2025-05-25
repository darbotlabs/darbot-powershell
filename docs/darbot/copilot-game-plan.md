# Copilot Agent Quest Log

Welcome, Copilot agent! Follow this quest-style checklist to get the repository automated and secure. Complete each step to level up your project.

## Level 1: Environment Setup

- [ ] **Install** Node.js and PowerShell dependencies using `Invoke-Build` or your preferred package manager.
- [ ] **Bootstrap** the repository by running `Start-PSBootstrap` to restore module dependencies.
- [ ] **Verify** that `pwsh` and `npm` commands are available by running `pwsh -v` and `npm --version`.

## Level 2: Configure Dependabot

- [ ] **Create** `.github/dependabot.yml` to monitor NuGet, npm and GitHub Actions updates.
- [ ] **Specify** the update schedule and target branch so automated PRs keep dependencies fresh.

## Level 3: Continuous Integration

- [ ] **Add** GitHub Actions workflows under `.github/workflows` to run `Invoke-Build` and Pester tests on pull requests.
- [ ] **Include** a job for linting using `PSScriptAnalyzer` and one for running `npm test` if applicable.
- [ ] **Publish** code coverage to Codecov or a similar service.

## Level 4: Packaging Automation

- [ ] **Add** an npm `package.json` script for packaging the modules.
- [ ] **Create** a VS Code Extension packaging pipeline if needed.
- [ ] **Document** how to run `npm pack` and `Start-PSPackage` to produce distributable artifacts.

## Level 5: Bonus Objectives

- [ ] **Enable** branch protection rules so CI must pass before merging.
- [ ] **Add** issue templates and PR templates in `.github` to guide contributors.
- [ ] **Review** the security settings in repository settings and enable secret scanning.

Complete these quests to unlock a fully automated and well-maintained project! Feel free to expand the tasks as your adventure continues.
