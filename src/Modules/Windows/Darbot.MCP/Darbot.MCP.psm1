# Darbot.MCP PowerShell module

function Get-MCPInfo {
    <#
        .SYNOPSIS
            Get basic information about the current MCP environment.
    #>
    [CmdletBinding()]
    param ()

    process {
        $info = [ordered]@{
            OS               = $PSVersionTable.OS
            PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        }
        [pscustomobject]$info
    }
}

function Invoke-MCPCommand {
    <#
        .SYNOPSIS
            Run a script block in the MCP context.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock
    )

    process {
        & $ScriptBlock
    }
}

