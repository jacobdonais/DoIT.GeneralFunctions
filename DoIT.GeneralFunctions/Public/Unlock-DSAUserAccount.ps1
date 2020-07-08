<#
.SYNOPSIS
    Unlocks an AD account.

.DESCRIPTION
    The Unlock-ADUserAccount function will unlock the account. This does not reset the password.

.NOTES

Author: Jacob Donais
Version: v1.1
Change Log:
    v1.0
        Initial build
    v1.1
        Adjusted output to show what's happening
#>

Function Unlock-DSAUserAccount {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Enter an AD username")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $null -ne (Get-ADUser -Filter "samaccountname -eq '$_'") })]
        [String]$UserName
    )

    BEGIN {
        Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
    }

    PROCESS {
        Write-Host "Attempting to unlock DSA account $((Get-ADUser -Filter "samaccountname -eq '$UserName'").Name)... " -NoNewline
        try {
            Unlock-ADAccount -Identity $UserName -Confirm:$false
            Write-Host "done"
        }
        catch {
            Write-Host "failed; please ensure you are running this as an admin and you have permission to make this change" -ForegroundColor Red
        }
    }
}
