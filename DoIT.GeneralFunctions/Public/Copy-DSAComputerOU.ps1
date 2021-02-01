<#
.SYNOPSIS
    Will copy the OU of another computer.

.DESCRIPTION
    The Copy-DSAComputerOU function will get the OU of the desired computer's OU and will set the
    computer input to that OU.

.EXAMPLE
    Get-ADComputer -filter "name -like 'DOIT-HP*'" | Copy-DSAComputerOU -DesiredComputerName DOIT-DELLLOAN-1

.INPUTS
    String

.OUTPUTS
    None

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build

#>

Function Copy-DSAComputerOU {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter a computer name")]
        [Alias('ComputerName', 'CN')]
        [ValidateNotNullOrEmpty()]
        [String[]]$Name,
        [Parameter(
            Mandatory=$true,
            HelpMessage="Enter the computer name for the desired OU")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADComputer -Filter "name -eq '$_'") -ne $null})]
        [String]$DesiredComputerName
    )

    BEGIN {
        Write-Host "Getting the desired OU... " -NoNewline
        try {
            $DesiredOU = ((Get-ADComputer -Filter "name -eq '$DesiredComputerName'" -ErrorAction Stop).distinguishedname -split ",",2)[1]
            $DesiredPath = (Get-ADComputer -Filter "name -eq '$DesiredComputerName'" -Properties * -ErrorAction Stop).canonicalName -replace $DesiredComputerName,""
            Write-Host "done; $DesiredPath" -ForegroundColor Yellow
        }
        catch {
            Write-Host "failed" -ForegroundColor Red
            exit
        }
    }

    PROCESS {
        Write-Host "Moving computer to the desired OU... " -NoNewline
        try {
            Get-ADComputer -Filter "name -eq '$ComputerName'" -ErrorAction Stop | Move-ADObject -TargetPath $DesiredOU -Confirm:$false -ErrorAction Stop
            Write-Host "done" -ForegroundColor Yellow
        }
        catch {
            Write-Host "faled" -ForegroundColor Red
        }
    }
}
