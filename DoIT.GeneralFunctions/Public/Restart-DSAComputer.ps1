<#
.SYNOPSIS
    Restarts a DSA computer

.DESCRIPTION
    The Restart-DSAComputer cmdlet will restart a computer and will report when the device is back on
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
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Connection $_ -Quiet -Count 1})]
        [String]$ComputerName,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Int]$TimeoutSeconds=60
    )

    Process {
        Write-Host "Restarting $ComputerName... " -NoNewline
        try {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock {Restart-Computer -Force}
            Write-Host "done"
        }
        catch {
            Write-Host "failed" -ForegroundColor Red
            break
        }

        Write-Host "Waiting for computer to shutdown completely..."
        $startDate = Get-Date
        while ((Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) -and ($startDate.AddSeconds($TimeoutSeconds*10) -gt (Get-Date))) {
            
        }
        if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
            Write-Host "$ComputerName failed to shutdown after $($TimeoutSeconds*10) seconds" -ForegroundColor Red
            break
        }
        else {
            Write-Host "$ComputerName is offline" -ForegroundColor Yellow
        }

        Write-Host "Waiting for response..."
        $startDate = Get-Date
        while (-not(Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) -and ($startDate.AddSeconds($TimeoutSeconds) -gt (Get-Date))) {
            Write-Host "No Reponse $(Get-Date)" -ForegroundColor Yellow
        }
        if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
            Write-Host "$ComputerName is online"
        }
        else {
            Write-Host "$ComputerName failed to communicate back after $TimeoutSeconds seconds" -ForegroundColor Red
            break
        }
    }
}
