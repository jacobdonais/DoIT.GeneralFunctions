<#
.SYNOPSIS
    Moves the Loaner to a different devices OU.

.DESCRIPTION
    The Move-DoITLoaner function move a loaner AD object to a desired computer's OU.

.INPUTS
    String

.OUPUTS
    None

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build

#>

Function Move-DoITLoaner {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Enter a computer name")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $null -ne (Get-ADComputer -Filter "name -eq '$_'") })]
        [String]$ComputerName,
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Enter a computer name")]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("^DOIT-(DELL|HP)LOAN-\d+$")]
        [ValidateScript( { $null -ne (Get-ADComputer -Filter "name -eq '$_'") })]
        [String]$LoanerName
    )

    BEGIN {
        Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
    }

    PROCESS {
        Write-Host "Getting Desired OU... " -NoNewline
        try {
            $DesiredOU = ((Get-ADComputer -Filter "name -eq '$ComputerName'").distinguishedname -split ",", 2)[1]
            $DesiredPath = (Get-ADComputer -Filter "name -eq '$ComputerName'" -Properties *).canonicalName -replace $ComputerName, ""
            Write-Host "done; $DesiredPath" -ForegroundColor Yellow
        }
        catch {
            Write-Host "failed" -ForegroundColor Red
        }

        Write-Host "Moving $LoanerName to Desired OU... " -NoNewline
        try {
            Get-ADComputer -Filter "name -eq '$LoanerName'" | Move-ADObject -TargetPath $DesiredOU -Confirm:$false
            Write-Host "done" -ForegroundColor Yellow
        }
        catch {
            Write-Host "faled" -ForegroundColor Red
        }
    }
}
