<#
.SYNOPSIS
    Returns the OU for a DSA User.

.DESCRIPTION
    The Get-DSAUserOU function returns the OU for the user.

.INPUTS
    String[]

.OUTPUTS
    String

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build

#>

Function Get-DSAUserOU {
    [CmdletBinding()]Param (
        [Parameter (Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $null -ne (Get-ADUser -Filter "samaccountname -eq '$_'") })]
        [String[]]$UserName
    )

    PROCESS {
        foreach ($U in $UserName) {
            Write-Host "$U"
            Write-Host $('-' * ($U.length))
            $UserOU = (Get-ADUser -Filter "SAMAccountname -eq '$U'" -Properties * -ErrorAction Stop).CanonicalName
            Write-Host "$UserOU"
        }
    }
}
