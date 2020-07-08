<#
.SYNOPSIS
    Unlocks an AD account.

.DESCRIPTION
    The Unlock-ADUserAccount cmdlet will unlock the account. This does not reset the password.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
#>

Function Unlock-DSAUserAccount {
	[CmdletBinding()]Param (
        [Parameter (Mandatory = $true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADUser -Filter "samaccountname -eq '$_'") -ne $null})]
        [String]$UserName
    )

    Process {
        try {
            Unlock-ADAccount -Identity $UserName
        }
        catch {
            Write-Host "failed; please ensure you are running this as an admin and you have permission to make this change" -ForegroundColor Red
        }
    }
}
