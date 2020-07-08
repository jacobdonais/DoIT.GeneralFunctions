<#
.SYNOPSIS
    Test if a given username is part of a group.

.DESCRIPTION
    The Test-MemberOf cmdlet determines if a member if a part of an AD group.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
#>

Function Test-MemberOf {
    [CmdletBinding()]Param (
        [Parameter (Mandatory = $true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADUser -Filter "samaccountname -eq '$_'") -ne $null})]
        [String] $UserName,
        [Parameter (Mandatory = $true)]
        [ValidateScript({(Get-ADGroup -Filter "SAMAccountName -eq '$_'") -ne $null})]
        [String] $ADGroup
    )

    Process {
        
        Write-Host "Collecting account information for $((Get-ADUser -Filter "samaccountname -eq '$UserName'").Name)..."
        $members = Get-ADGroupMember -Identity $ADGroup -Recursive | Select -ExpandProperty SamAccountName

        If ($members -contains $username) {
            Write-Host "$UserName is a member of $ADGroup" -ForegroundColor Yellow
        } Else {
            Write-Host "$UserName is not a member of $ADGroup" -ForegroundColor DarkYellow
        }
    }
}
