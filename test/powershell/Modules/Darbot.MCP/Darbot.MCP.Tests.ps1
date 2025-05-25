Describe "Darbot.MCP module" -Tags "CI" {
    It "Get-MCPInfo returns environment info" {
        $info = Get-MCPInfo
        $info | Should -BeOfType psobject
        $info.OS | Should -Not -BeNullOrEmpty
    }

    It "Invoke-MCPCommand executes script block" {
        Invoke-MCPCommand { 2 + 2 } | Should -Be 4
    }
}
