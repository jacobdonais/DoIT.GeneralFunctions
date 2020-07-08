<#
.SYNOPSIS
    Resets an AD account to a temporary password and flags it to change on next login.

.DESCRIPTION
    The Reset-ADUserPassword cmdlet will reset the temporary password and flag it to change on next login.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
#>

Function Reset-DSAUserPassword {
	[CmdletBinding()]Param (
        [Parameter (Mandatory = $true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADUser -Filter "samaccountname -eq '$_'") -ne $null})]
        [String]$UserName,
        [Parameter (Mandatory = $true,Position=1)]
        [ValidateNotNullOrEmpty()]
        [String]$Password
    )

    Process {
        try {
	        Set-ADAccountPassword -Identity $UserName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)
		    Set-ADUser -Identity $UserName -ChangePasswordAtLogon $true
            Unlock-ADAccount -Identity $UserName
        }
        catch {
            Write-Host "failed; please ensure you are running this as an admin and you have permission to make this change" -ForegroundColor Red
        }
    }
}
