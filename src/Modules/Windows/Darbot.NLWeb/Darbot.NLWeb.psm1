# Darbot.NLWeb PowerShell module

function Get-NLWebContent {
    <#
        .SYNOPSIS
            Retrieve content from a web endpoint using Invoke-RestMethod.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Uri
    )

    process {
        Invoke-RestMethod -Uri $Uri
    }
}

function Test-NLWebConnection {
    <#
        .SYNOPSIS
            Test whether a web endpoint is reachable.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Uri
    )

    process {
        try {
            Invoke-WebRequest -Uri $Uri -Method Head -ErrorAction Stop | Out-Null
            $true
        } catch {
            $false
        }
    }
}

