<#
.SYNOPSIS
    Returns the OU for a DSA Computer.

.DESCRIPTION
    The Get-DSAComputerOU function returns the OU for the computer.

.INPUTS
    String[]

    A computer object that was retrieved by using the Get-ADComputer cmdlet and then modified is received by the Instance parameter.

.OUTPUTS
    String

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build

#>

Function Get-DSAComputerOU {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter a computer name")]
        [Alias('ComputerName', 'CN')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADComputer -Filter "name -eq '$_'") -ne $null})]
        [String[]]$Name = $env:COMPUTERNAME
    )

    PROCESS {
        foreach ($C in $Name) {
            Write-Host "$C"
            Write-Host $('-' * ($C.length))
            $ComputerOU = (Get-ADComputer -Filter "name -eq '$C'" -Properties * -ErrorAction Stop).CanonicalName
            Write-Host "$ComputerOU"
        }
    }
}
