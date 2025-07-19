@{
    GUID = "11111111-1111-1111-1111-111111111111"
    Author = "Darbot"
    CompanyName = "Darbot"
    ModuleVersion = "0.2.0"
    CompatiblePSEditions = @("Core")
    PowerShellVersion = "3.0"
    RootModule = "Darbot.MCP.psm1"
    FunctionsToExport = @(
        "Get-MCPInfo",
        "Invoke-MCPCommand",
        "Start-MCPServer",
        "Stop-MCPServer",
        "Invoke-MCPScript",
        "Invoke-MCPServerRequest"
    )
    Description = "PowerShell module implementing Model Context Protocol (MCP) server functionality for AI assistant integration"
    RequiredModules = @()
}
