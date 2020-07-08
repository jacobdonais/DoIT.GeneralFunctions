<#
.SYNOPSIS
    Debugs a DSA computer and points out obvious problems.

.DESCRIPTION
    The Debug-DSAComputer cmdlet output basic warnings on a given device

.EXAMPLE
    PS > Debug-DSAComputer -Name DOITTECH-227-6

    Collecting information for DOITTECH-227-6...
    End of Report on DOITTECH-227-6.

.EXAMPLE
    PS > Debug-DSAComputer -Name NOT-IN-AD

    Collecting information for NOT-IN-AD...
    WARNING: AD Object does not exist for NOT-IN-AD. Please check computer name spelling.
    End of Report on NOT-IN-AD.

.EXAMPLE
    PS > Get-ADComputer -Filter "name -like 'doittech*'" | Debug-DSAComputer

    Collecting information for DOITTECH-227-1...
    End of Report on DOITTECH-227-1.
    Collecting information for DOITTECH-227-2...
    End of Report on DOITTECH-227-2.
    Collecting information for DOITTECH-227-3...
    End of Report on DOITTECH-227-3.
    Collecting information for DOITTECH-227-4...
    End of Report on DOITTECH-227-4.
    Collecting information for DOITTECH-227-5...
    End of Report on DOITTECH-227-5.
    Collecting information for DOITTECH-227-6...
    End of Report on DOITTECH-227-6.

.EXAMPLE
    PS > Debug-DSAComputer -Name "DOITTECH-227-1","DOITTECH-227-2"

.NOTES

Author: Jacob Donais
Version: v1.2
Change Log:
    v1.0
        Initial build
    v1.1
        Improved logic
    v1.2
        Added Examples for standard, pipeline, and array.
#>

Function Debug-DSAComputer {
    [CmdletBinding()]Param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter a computer name")]
        [Alias('ComputerName', 'CN')]
        [ValidateNotNullOrEmpty()]
        [String[]]$Name
    )

    PROCESS {
        foreach ($C in $Name) {
            Write-Host "Collecting information for $C..." -ForegroundColor Yellow

            # Test if an AD object exists for said computer
            Write-Verbose "Testing if AD Computer object exists..."
            $ADComputer = Get-ADComputer -Filter "name -eq '$C'" -Properties *
            if (-not($ADComputer)) {
                Write-Warning "AD Object does not exist for $C. Please check computer name spelling."
            }
            else {
                # Test if the object is online
                Write-Verbose "Testing if Computer is online..."
                if (-not(Test-Connection -ComputerName $C -Count 1 -Quiet)) {
                    Write-Warning "$C is either offline or Hostname IP mapping is incorrect."
                }

                # Test if AD object is enabled
                Write-Verbose "Testing if AD Computer object is enabled..."
                if ($ADComputer.Enabled -eq $false) {
                    Write-Warning "AD Object is disabled."
                }

                # Test if computer is running Windows 7
                Write-Verbose "Testing if computer is running Windows 7..."
                if ($ADComputer.OperatingSystem -eq 'Windows 7 Enterprise') {
                    Write-Warning "Device is running Windows 7. This device needs to be upgraded."
                }

                # Test if computer is named MININT
                Write-Verbose "Testing if computer is named correctly..."
                if ($C -match "MININT") {
                    Write-Warning "Computer is named incorrectly; is MININT"
                }

                # Test OU
                Write-Verbose "Testing computer OU..."
                if ($ADComputer.CanonicalName -notmatch "Department") {
                    Write-Warning "Computer is not in a Department OU. $($ADComputer.CanonicalName)"
                }
                elseif ($ADComputer.CanonicalName -match "IT Dumpster") {
                    Write-Warning "Computer is in the IT Dumpster OU."
                }
            
            }

            Write-Host "End of Report on $C." -ForegroundColor Yellow
        }
    }
}
