<#
.SYNOPSIS
    Test if a computer is online.

.DESCRIPTION
    The Test-ComputerConnection cmdlet returns true/false if a computer is online.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
#>

Function Test-ComputerConnection {
    [CmdletBinding()]Param (
        [Parameter(
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        HelpMessage="Enter a computer name")]
        [Alias('ComputerName', 'CN')]
        [ValidateNotNullOrEmpty()]
        [String[]]$Name
    )

    Process {
        foreach ($N in $Name) {
            New-Object psobject -Property @{
                ComputerName = "$N"
                Online = (Test-Connection $N -Quiet -Count 1)
            }
        }
    }
}
