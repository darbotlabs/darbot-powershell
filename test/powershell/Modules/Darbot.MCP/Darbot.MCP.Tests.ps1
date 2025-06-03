Describe "Darbot.MCP module" -Tags "CI" {
    It "Get-MCPInfo returns environment info" {
        $info = Get-MCPInfo
        $info | Should -BeOfType psobject
        $info.OS | Should -Not -BeNullOrEmpty
        $info.MCPServerStatus | Should -Be "Stopped"
        $info.MCPServerPort | Should -Be $null
    }

    It "Invoke-MCPCommand executes script block" {
        Invoke-MCPCommand { 2 + 2 } | Should -Be 4
    }

    It "Invoke-MCPScript executes PowerShell commands" {
        $result = Invoke-MCPScript -Script "2 + 2"
        $result.Success | Should -Be $true
        $result.Output | Should -Match "4"
        $result.Error | Should -Be $null
    }

    It "Invoke-MCPScript handles errors gracefully" {
        $result = Invoke-MCPScript -Script "throw 'test error'"
        $result.Success | Should -Be $false
        $result.Error | Should -Match "test error"
    }

    Context "MCP Server Operations" {
        BeforeAll {
            # Ensure no server is running
            Stop-MCPServer -ErrorAction SilentlyContinue
        }

        AfterAll {
            # Clean up
            Stop-MCPServer -ErrorAction SilentlyContinue
        }

        It "Start-MCPServer starts the server" {
            Start-MCPServer -Port 8081
            $info = Get-MCPInfo
            $info.MCPServerStatus | Should -Be "Running"
            $info.MCPServerPort | Should -Be 8081
        }

        It "Stop-MCPServer stops the server" {
            Stop-MCPServer
            $info = Get-MCPInfo
            $info.MCPServerStatus | Should -Be "Stopped"
        }

        It "Start-MCPServer warns when server is already running" {
            Start-MCPServer -Port 8082
            { Start-MCPServer -Port 8083 } | Should -Not -Throw
            Stop-MCPServer
        }

        It "Invoke-MCPServerRequest handles timeout correctly" {
            Start-MCPServer -Port 8086
            $result = Invoke-MCPServerRequest -TimeoutSeconds 1
            $result.Status | Should -Be "Timeout waiting for request"
            Stop-MCPServer
        }
    }

    Context "MCP Protocol Integration" {
        BeforeAll {
            Stop-MCPServer -ErrorAction SilentlyContinue
        }

        AfterAll {
            Stop-MCPServer -ErrorAction SilentlyContinue
        }

        It "Server responds to tools/list requests correctly" {
            Start-MCPServer -Port 8087
            
            # Send request in background
            $job = Start-Job -ScriptBlock {
                Start-Sleep 1
                $request = @{
                    jsonrpc = "2.0"
                    id = 1
                    method = "tools/list"
                } | ConvertTo-Json
                
                Invoke-WebRequest -Uri "http://localhost:8087/" -Method POST -ContentType "application/json" -Body $request -UseBasicParsing
            }
            
            # Process request
            $result = Invoke-MCPServerRequest -TimeoutSeconds 10
            $result.Status | Should -Be "Request processed successfully"
            $result.Method | Should -Be "tools/list"
            
            $job | Wait-Job | Remove-Job
            Stop-MCPServer
        }

        It "Server executes PowerShell commands via tools/call" {
            Start-MCPServer -Port 8088
            
            # Send request in background
            $job = Start-Job -ScriptBlock {
                Start-Sleep 1
                $request = @{
                    jsonrpc = "2.0"
                    id = 2
                    method = "tools/call"
                    params = @{
                        name = "run_powershell"
                        arguments = @{
                            command = "Write-Output 'Hello MCP'"
                        }
                    }
                } | ConvertTo-Json -Depth 10
                
                Invoke-WebRequest -Uri "http://localhost:8088/" -Method POST -ContentType "application/json" -Body $request -UseBasicParsing
            }
            
            # Process request
            $result = Invoke-MCPServerRequest -TimeoutSeconds 10
            $result.Status | Should -Be "Request processed successfully"
            $result.Method | Should -Be "tools/call"
            $result.Response.result.content[0].text | Should -Match "Hello MCP"
            
            $job | Wait-Job | Remove-Job
            Stop-MCPServer
        }
    }
}
