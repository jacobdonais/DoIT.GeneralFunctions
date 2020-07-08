<#
.SYNOPSIS
    Debugs a DSA computer and points out obvious problems.

.DESCRIPTION
    The Debug-DSAComputer cmdlet output basic warnings on a given device

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
#>

Function Debug-DSAComputer {
    [CmdletBinding()]Param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            HelpMessage="Enter an AD computer name")]
        [ValidateNotNullOrEmpty()]
        [String]$ComputerName
    )

    Process {
        Write-Host "Collecting information for $ComputerName..." -ForegroundColor Yellow

        # Test if an AD object exists for said computer
        Write-Verbose "Testing if AD Computer object exists..."
        $ADComputer = Get-ADComputer -Filter "name -eq '$ComputerName'" -Properties *
        if (-not($ADComputer)) {
            Write-Warning "AD Object does not exist for $ComputerName"
        }
        else {
            # Test if the object is online
            Write-Verbose "Testing if Computer is online..."
            if (-not(Test-Connection -ComputerName $ComputerName -Count 1 -Quiet)) {
                Write-Warning "$ComputerName is offline"
            }

            # Test if AD object is enabled
            Write-Verbose "Testing if AD Computer object is enabled..."
            if ($ADComputer.Enabled -eq $false) {
                Write-Warning "AD Object is disabled"
            }

            # Test if computer is running Windows 7
            Write-Verbose "Testing if computer is running Windows 7..."
            if ($ADComputer.OperatingSystem -eq 'Windows 7 Enterprise') {
                Write-Warning "Device is running Windows 7"
            }

            # Test if computer is named MININT
            Write-Verbose "Testing if computer is named correctly..."
            if ($ADComputer -match "MININT") {
                Write-Warning "Computer is named incorrectly; is MININT"
            }

            # Test if computer is in a department OU
            Write-Verbose "Testing if computer is in a department OU..."
            if ($ADComputer.CanonicalName -notmatch "Department") {
                Write-Warning "Computer is not in a Department OU"
            }

            # Test if computer is in the newly imaged computer collection
            Write-Verbose "Testing if computer is in the newly imaged computers OU..."
            if ($ADComputer.CanonicalName -match "Newly Imaged Computers") {
                Write-Warning "Computer is in the Newly Imaged Computers OU"
            }
            
        }

        Write-Host "End of Report on $ComputerName." -ForegroundColor Yellow
    }
}
