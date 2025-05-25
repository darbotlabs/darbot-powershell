# Building Darbot Modules

The build system can package `Darbot.MCP` and `Darbot.NLWeb` as optional modules.
These modules are restored from the PowerShell Gallery when `Start-PSBuild` is
run with module restore enabled.

`Darbot.MCP` provides helper functions `Get-MCPInfo` and `Invoke-MCPCommand` for
interacting with the MCP environment. `Darbot.NLWeb` includes `Get-NLWebContent`
and `Test-NLWebConnection` for basic web requests.

1. Ensure the repository is bootstrapped as described in the standard build
documentation.
2. Run `Start-PSBuild -PSModuleRestore` to fetch the modules.
3. Use `Start-PSPackage` to create packages. The modules will appear under the
`Modules` folder of the output and can be distributed separately.
