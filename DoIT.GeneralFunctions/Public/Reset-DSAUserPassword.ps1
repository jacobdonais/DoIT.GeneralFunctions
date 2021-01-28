<#
.SYNOPSIS
    Resets an AD account to a temporary password and flags it to change on next login.

.DESCRIPTION
    The Reset-ADUserPassword cmdlet will reset the temporary password and flag it to change on next login.
    If needed, the user can reset their password at https://remoteapps.tamu.edu/RDWeb/Pages/en-US/password.aspx

.NOTES

Author: Jacob Donais
Version: v1.1
Change Log:
    v1.0
        Initial build
    v1.1
        Adjusted output to be cleaner.
        Added password requirements.
#>

Function Reset-DSAUserPassword {
	[CmdletBinding()]Param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter an AD username")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADUser -Filter "samaccountname -eq '$_'") -ne $null})]
        [String]$UserName,
        [Parameter (Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Password
    )

    PROCESS {
        $PasswordRequirement = "$PSScriptRoot\..\Resources\Users\PasswordRequirement"

        try {
	        Set-ADAccountPassword -Identity $UserName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)
		    Set-ADUser -Identity $UserName -ChangePasswordAtLogon $true
            Unlock-ADAccount -Identity $UserName

            Write-Host "Username: $Username"
            Write-Host "Temp password is: $Password"
            Get-Content -Path $PasswordRequirement
        }
        catch {
            Write-Host "failed; please ensure you are running this as an admin and you have permission to make this change" -ForegroundColor Red
        }
    }
}
