# Darbot.MCP PowerShell module

# Global variable to store MCP server state
$script:MCPServer = $null

function Get-MCPInfo {
    <#
        .SYNOPSIS
            Get basic information about the current MCP environment.
    #>
    [CmdletBinding()]
    param ()

    process {
        $info = [ordered]@{
            OS                = $PSVersionTable.OS
            PowerShellVersion = $PSVersionTable.PSVersion.ToString()
            MCPServerStatus   = if ($script:MCPServer) { "Running" } else { "Stopped" }
            MCPServerPort     = if ($script:MCPServer) { $script:MCPServer.Port } else { $null }
        }
        [pscustomobject]$info
    }
}

function Invoke-MCPCommand {
    <#
        .SYNOPSIS
            Run a script block in the MCP context.
        .DESCRIPTION
            Executes a PowerShell script block and returns the result.
        .PARAMETER ScriptBlock
            The script block to execute.
        .EXAMPLE
            Invoke-MCPCommand { Get-Process | Select-Object -First 5 }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock
    )

    process {
        try {
            $result = & $ScriptBlock
            return $result
        }
        catch {
            Write-Error "Error executing script block: $_"
            throw
        }
    }
}

function Start-MCPServer {
    <#
        .SYNOPSIS
            Start the MCP server for handling Model Context Protocol requests.
        .DESCRIPTION
            Starts an HTTP server that implements the Model Context Protocol to handle
            requests from AI assistants like GitHub Copilot.
        .PARAMETER Port
            The port to listen on for MCP requests. Default is 8080.
        .PARAMETER AllowedOrigins
            Array of allowed origins for CORS. Default allows all origins.
        .EXAMPLE
            Start-MCPServer -Port 8080
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [int]$Port = 8080,
        
        [Parameter()]
        [string[]]$AllowedOrigins = @("*")
    )

    process {
        if ($PSCmdlet.ShouldProcess("MCP Server", "Start on port $Port")) {
            if ($script:MCPServer) {
                Write-Warning "MCP Server is already running on port $($script:MCPServer.Port)"
                return
            }

            try {
                Write-Host "Starting MCP Server on port $Port..."
            
            # Create HTTP listener
            $listener = New-Object System.Net.HttpListener
            $listener.Prefixes.Add("http://localhost:$Port/")
            $listener.Start()
            
            $script:MCPServer = @{
                Listener = $listener
                Port = $Port
                AllowedOrigins = $AllowedOrigins
                IsRunning = $true
            }
            
            Write-Host "MCP Server started successfully on http://localhost:$Port"
            Write-Host "Note: Use Stop-MCPServer to stop the server"
            
        }
        catch {
            Write-Error "Failed to start MCP Server: $_"
            if ($listener) {
                $listener.Stop()
                $listener.Dispose()
            }
            $script:MCPServer = $null
            throw
        }
        }
    }
}

function Invoke-MCPServerRequest {
    <#
        .SYNOPSIS
            Process a single MCP server request (for testing purposes).
        .DESCRIPTION
            Processes one incoming request on the MCP server. This is primarily
            intended for testing and development.
        .PARAMETER TimeoutSeconds
            How long to wait for a request. Default is 10 seconds.
        .EXAMPLE
            Invoke-MCPServerRequest -TimeoutSeconds 5
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$TimeoutSeconds = 10
    )

    process {
        if (-not $script:MCPServer -or -not $script:MCPServer.Listener.IsListening) {
            throw "MCP Server is not running. Use Start-MCPServer first."
        }

        try {
            # Get context with timeout
            $asyncResult = $script:MCPServer.Listener.BeginGetContext($null, $null)
            $waitHandle = $asyncResult.AsyncWaitHandle
            
            if ($waitHandle.WaitOne([TimeSpan]::FromSeconds($TimeoutSeconds))) {
                $context = $script:MCPServer.Listener.EndGetContext($asyncResult)
                
                $request = $context.Request
                $response = $context.Response
                
                # Set CORS headers
                $response.Headers.Add("Access-Control-Allow-Origin", "*")
                $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
                $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type")
                
                if ($request.HttpMethod -eq "OPTIONS") {
                    $response.StatusCode = 200
                    $response.Close()
                    return @{ Status = "CORS preflight handled" }
                }
                
                if ($request.HttpMethod -eq "POST") {
                    $reader = New-Object System.IO.StreamReader($request.InputStream)
                    $requestBody = $reader.ReadToEnd()
                    $reader.Close()
                    
                    try {
                        $mcpRequest = $requestBody | ConvertFrom-Json
                        
                        # Handle MCP protocol messages
                        $result = switch ($mcpRequest.method) {
                            "tools/list" {
                                @{
                                    jsonrpc = "2.0"
                                    id = $mcpRequest.id
                                    result = @{
                                        tools = @(
                                            @{
                                                name = "run_powershell"
                                                description = "Execute PowerShell commands and scripts"
                                                inputSchema = @{
                                                    type = "object"
                                                    properties = @{
                                                        command = @{
                                                            type = "string"
                                                            description = "PowerShell command or script to execute"
                                                        }
                                                    }
                                                    required = @("command")
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                            "tools/call" {
                                $toolName = $mcpRequest.params.name
                                $arguments = $mcpRequest.params.arguments
                                
                                if ($toolName -eq "run_powershell") {
                                    $command = $arguments.command
                                    try {
                                        $scriptBlock = [scriptblock]::Create($command)
                                        $output = & $scriptBlock | Out-String
                                        
                                        @{
                                            jsonrpc = "2.0"
                                            id = $mcpRequest.id
                                            result = @{
                                                content = @(
                                                    @{
                                                        type = "text"
                                                        text = $output
                                                    }
                                                )
                                            }
                                        }
                                    }
                                    catch {
                                        @{
                                            jsonrpc = "2.0"
                                            id = $mcpRequest.id
                                            error = @{
                                                code = -32603
                                                message = "Internal error: $($_.Exception.Message)"
                                            }
                                        }
                                    }
                                }
                                else {
                                    @{
                                        jsonrpc = "2.0"
                                        id = $mcpRequest.id
                                        error = @{
                                            code = -32602
                                            message = "Invalid tool name: $toolName"
                                        }
                                    }
                                }
                            }
                            default {
                                @{
                                    jsonrpc = "2.0"
                                    id = $mcpRequest.id
                                    error = @{
                                        code = -32601
                                        message = "Method not found: $($mcpRequest.method)"
                                    }
                                }
                            }
                        }
                        
                        $responseText = $result | ConvertTo-Json -Depth 10
                        $responseBytes = [System.Text.Encoding]::UTF8.GetBytes($responseText)
                        
                        $response.ContentType = "application/json"
                        $response.ContentLength64 = $responseBytes.Length
                        $response.OutputStream.Write($responseBytes, 0, $responseBytes.Length)
                        $response.Close()
                        
                        return @{ 
                            Status = "Request processed successfully"
                            Method = $mcpRequest.method
                            Response = $result
                        }
                    }
                    catch {
                        $errorResponse = @{
                            jsonrpc = "2.0"
                            id = $null
                            error = @{
                                code = -32700
                                message = "Parse error: $($_.Exception.Message)"
                            }
                        } | ConvertTo-Json
                        
                        $responseBytes = [System.Text.Encoding]::UTF8.GetBytes($errorResponse)
                        $response.ContentType = "application/json"
                        $response.ContentLength64 = $responseBytes.Length
                        $response.OutputStream.Write($responseBytes, 0, $responseBytes.Length)
                        $response.Close()
                        
                        return @{ Status = "Parse error"; Error = $_.Exception.Message }
                    }
                }
                else {
                    $response.StatusCode = 405 # Method Not Allowed
                    $response.Close()
                    return @{ Status = "Method not allowed" }
                }
            }
            else {
                return @{ Status = "Timeout waiting for request" }
            }
        }
        catch {
            Write-Error "Error processing MCP request: $_"
            return @{ Status = "Error"; Error = $_.Exception.Message }
        }
    }
}

function Stop-MCPServer {
    <#
        .SYNOPSIS
            Stop the running MCP server.
        .DESCRIPTION
            Stops the MCP server and cleans up resources.
        .EXAMPLE
            Stop-MCPServer
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        if ($PSCmdlet.ShouldProcess("MCP Server", "Stop")) {
            if (-not $script:MCPServer) {
                Write-Warning "MCP Server is not running"
                return
            }

            try {
                Write-Host "Stopping MCP Server..."
            
            # Stop the server
            $script:MCPServer.IsRunning = $false
            $script:MCPServer.Listener.Stop()
            $script:MCPServer.Listener.Dispose()
            
            $script:MCPServer = $null
            
            Write-Host "MCP Server stopped successfully"
        }
        catch {
            Write-Error "Error stopping MCP Server: $_"
            $script:MCPServer = $null
            throw
        }
        }
    }
}

function Invoke-MCPScript {
    <#
        .SYNOPSIS
            Execute a PowerShell script via MCP protocol.
        .DESCRIPTION
            Executes a PowerShell script or command and returns the result in a format
            suitable for MCP clients like GitHub Copilot.
        .PARAMETER Script
            The PowerShell script or command to execute.
        .PARAMETER TimeoutSeconds
            Maximum time to wait for script execution. Default is 30 seconds.
        .EXAMPLE
            Invoke-MCPScript -Script "Get-Process | Select-Object -First 5"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Script,
        
        [Parameter()]
        [int]$TimeoutSeconds = 30
    )

    process {
        try {
            $job = Start-Job -ScriptBlock {
                param($ScriptToRun)
                try {
                    $scriptBlock = [scriptblock]::Create($ScriptToRun)
                    $result = & $scriptBlock
                    return @{
                        Success = $true
                        Output = $result | Out-String
                        Error = $null
                    }
                }
                catch {
                    return @{
                        Success = $false
                        Output = $null
                        Error = $_.Exception.Message
                    }
                }
            } -ArgumentList $Script
            
            $result = $job | Wait-Job -Timeout $TimeoutSeconds | Receive-Job
            $job | Remove-Job
            
            if (-not $result) {
                throw "Script execution timed out after $TimeoutSeconds seconds"
            }
            
            return $result
        }
        catch {
            Write-Error "Error executing MCP script: $_"
            throw
        }
    }
}

