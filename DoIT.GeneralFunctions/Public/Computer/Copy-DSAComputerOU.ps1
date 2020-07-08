<#
.SYNOPSIS
    Will copy the OU of another computer.

.DESCRIPTION
    The Copy-DSAComputerOU cmdlet will get the OU of the desired computer's OU and will set the
    computer input to that OU.

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
            HelpMessage="Enter the computer name")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADComputer -Filter "name -eq '$_'") -ne $null})]
        [String]$ComputerName,
        [Parameter(
            Mandatory=$true,
            HelpMessage="Enter the computer name for the desired OU")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADComputer -Filter "name -eq '$_'") -ne $null})]
        [String]$DesiredComputerName
    )

    PROCESS {
        Write-Host "Getting the desired OU... " -NoNewline
        try {
            $DesiredOU = ((Get-ADComputer -Filter "name -eq '$DesiredComputerName'" -ErrorAction Stop).distinguishedname -split ",",2)[1]
            $DesiredPath = (Get-ADComputer -Filter "name -eq '$DesiredComputerName'" -Properties * -ErrorAction Stop).canonicalName -replace $DesiredComputerName,""
            Write-Host "done; $DesiredPath" -ForegroundColor Yellow
        }
        catch {
            Write-Host "failed" -ForegroundColor Red
        }

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
