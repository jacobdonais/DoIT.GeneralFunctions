<#
.SYNOPSIS
    Queries a given AD username for their security groups.

.DESCRIPTION
    If the user account exist, it will return a powershell object containing the username
    and security groups.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
#>

Function Get-DSAUserGroups {
    [CmdletBinding()]Param (
        [Parameter (Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $null -ne (Get-ADUser -Filter "samaccountname -eq '$_'") })]
        [String]$UserName
    )

    PROCESS {
        Write-Host "Collecting groups for $((Get-ADUser -Filter "samaccountname -eq '$UserName'").Name)..." -ForegroundColor Yellow
        $UserGroups = Get-ADPrincipalGroupMembership -Identity $UserName
        $UserGroups.name
    }
}
