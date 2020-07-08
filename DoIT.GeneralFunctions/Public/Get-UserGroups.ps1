<#
.SYNOPSIS
    Queries a given AD username for their security groups and copies to clipboard

.DESCRIPTION
    If the user account exist, it will return an powershell object containing the username
    and security groups and will set your clipboard to the groups. If the user account does 
    not exist, it will return null and set the clipboard to null.

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
        [ValidateScript({(Get-ADUser -Filter "samaccountname -eq '$_'") -ne $null})]
        [String]$UserName
    )

    Process {
        Write-Host "Collecting account information for $((Get-ADUser -Filter "samaccountname -eq '$UserName'").Name)..." -ForegroundColor Yellow
        $UserGroups = Get-ADPrincipalGroupMembership -Identity $UserName
        Set-Clipboard ($UserGroups.name)
        $UserGroups.name
    }
}
