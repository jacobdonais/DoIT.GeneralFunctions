<#
.SYNOPSIS
    Reset the OU of a loaner back to checkout equipment.

.DESCRIPTION
    The Reset-DoITLoaner cmdlet will move a loaner AD object back to the DoIT checkout
    equipment OU.

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

Function Reset-DoITLoaner {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$true,
            HelpMessage="Enter a computer name")]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("^DOIT-(DELL|HP)LOAN-\d+$")]
        [ValidateScript({(Get-ADComputer -Filter "name -eq '$_'") -ne $null})]
        [String]$LoanerName
    )

    PROCESS {
        $LoanerOU = "OU=Desktop,OU=Windows 10 Computers,OU=Checkout Equipment,OU=Dept of Information Technology,OU=Departments,OU=Student Affairs,DC=dsa,DC=reldom,DC=tamu,DC=edu"
        
        Write-Host "Moving $LoanerName to Loaner OU... " -NoNewline
        try {
            Get-ADComputer -Filter "name -eq '$LoanerName'" | Move-ADObject -TargetPath $LoanerOU -Confirm:$false
            Write-Host "done" -ForegroundColor Yellow
        }
        catch {
            Write-Host "failed" -ForegroundColor Red
        }
        
    }
}
