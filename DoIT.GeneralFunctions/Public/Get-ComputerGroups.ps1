<#
.SYNOPSIS
    Queries a given AD computer for their security groups and copies to clipboard

.DESCRIPTION
    The Get-ComputerGroups cmdlet will return the groups for a given computer. If the
    computer exists in AD then it will set it to the clipboard.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
#>

Function Get-UserGroups {
    [CmdletBinding()]Param (
        [Parameter (Mandatory = $true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADComputer -Filter "name -eq '$_'") -ne $null})]
        [String]$ComputerName
    )

    Process {
        Write-Host "Collecting group information for $ComputerName..." -ForegroundColor Yellow
        $ComputerGroups = Get-ADComputer -Filter "name -eq '$ComputerName'"| Get-ADPrincipalGroupMembership
        Set-Clipboard ($ComputerGroups.name)
        $ComputerGroups.name
    }
}
