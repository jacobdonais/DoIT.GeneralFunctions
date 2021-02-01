<#
.SYNOPSIS
    Restarts a DSA computer

.DESCRIPTION
    The Restart-DSAComputer function will restart a computer and will report when the device is back on
    or if the device failed to communicate back after $TimeoutSeconds

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
#>

Function Restart-DSAComputer {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter a computer name")]
        [Alias('ComputerName', 'CN')]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Int]$TimeoutSeconds=120,
        [Switch]$Force
    )

    PROCESS {
        if ([string]::IsNullOrEmpty((Get-DSALoggedOnUser -ComputerName $Name).USERNAME) -or $Force) {

            Write-Host "Restarting $Name... " -NoNewline
            try {
                Invoke-Command -ComputerName $Name -ScriptBlock {Restart-Computer -Force}
                Write-Host "done"
            }
            catch {
                Write-Host "failed" -ForegroundColor Red
                break
            }

            Write-Host "Waiting for computer to shutdown completely..."
            $startDate = Get-Date
            while ((Test-Connection -ComputerName $Name -Count 1 -Quiet) -and ($startDate.AddSeconds($TimeoutSeconds*10) -gt (Get-Date))) {
                Write-Host "Still online $(Get-Date)" -ForegroundColor Yellow
                Start-Sleep -Seconds 5
            }
            if (Test-Connection -ComputerName $Name -Count 1 -Quiet) {
                Write-Host "$Name failed to shutdown after $($TimeoutSeconds*10) seconds" -ForegroundColor Red
                break
            }
            else {
                Write-Host "$Name is offline" -ForegroundColor Yellow
            }

            Write-Host "Waiting for response..."
            $startDate = Get-Date
            while (-not(Test-Connection -ComputerName $Name -Count 1 -Quiet) -and ($startDate.AddSeconds($TimeoutSeconds) -gt (Get-Date))) {
                Write-Host "No Response $(Get-Date)" -ForegroundColor Yellow
            }
            if (Test-Connection -ComputerName $Name -Count 1 -Quiet) {
                Write-Host "$Name is online"
            }
            else {
                Write-Host "$Name failed to communicate back after $TimeoutSeconds seconds" -ForegroundColor Red
                break
            }

        }
        else {
            Write-Host "User is currently logged in on $Name. Try running again with -Force" -ForegroundColor Red
        }
    }
}
