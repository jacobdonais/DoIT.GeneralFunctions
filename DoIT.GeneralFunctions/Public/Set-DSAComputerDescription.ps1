<#
.SYNOPSIS
    Will set the description for an AD computer object

.DESCRIPTION
    The Set-DSAComputerDescription function will set the AD computer object description.

.INPUTS
    String[]

    A computer object that was retrieved by using the Get-ADComputer cmdlet and then modified is received by the Instance parameter.

.OUTPUTS
    None

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build

#>

Function Set-DSAComputerDescription {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Enter a computer name")]
        [Alias('ComputerName', 'CN')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $null -ne (Get-ADComputer -Filter "name -eq '$_'") })]
        [String[]]$Name,
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Enter a description")]
        [ValidateNotNullOrEmpty()]
        [String]$Description
    )

    BEGIN {
        Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
    }

    PROCESS {
        foreach ($C in $Name) {
            Write-Host "Applying description to $C... " -NoNewline
            try {
                Get-ADComputer -Filter "name -eq '$C'" | Set-ADComputer -Description $Description -ErrorAction Stop
                Write-Host "done; $Description" -ForegroundColor Yellow
            }
            catch {
                Write-Host "faled" -ForegroundColor Red
            }
        }
    }
}
