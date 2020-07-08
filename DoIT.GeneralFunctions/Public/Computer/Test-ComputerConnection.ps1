<#
.SYNOPSIS
    Test if a computer is online.

.DESCRIPTION
    The Test-ComputerConnection cmdlet returns true/false if a computer is online.

.EXAMPLE
    PS > Test-ComputerConnection -ComputerName DOITTECH-227-6

    ComputerName   Online
    ------------   ------
    DOITTECH-227-6   True

.EXAMPLE
    PS > Get-ADComputer -Filter "name -like 'DOITTECH*'" | Test-ComputerConnection

    ComputerName   Online
    ------------   ------
    DOITTECH-227-1   True
    DOITTECH-227-2   True
    DOITTECH-227-3   True
    DOITTECH-227-4   True
    DOITTECH-227-5   True
    DOITTECH-227-6   True

.NOTES

Author: Jacob Donais
Version: v1.1
Change Log:
    v1.0
        Initial build
    v1.1
        Added examples
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

    PROCESS {
        foreach ($N in $Name) {
            New-Object psobject -Property @{
                ComputerName = "$N"
                Online = (Test-Connection $N -Quiet -Count 1)
            }
        }
    }
}
