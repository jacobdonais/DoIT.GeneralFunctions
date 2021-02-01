<#
.SYNOPSIS
    Will rename a computer and restart it.

.DESCRIPTION
    The Rename-DSAComputer function will rename a computer if no user is logged in or if the force switch is added.
    It will also restart the computer.

.EXAMPLE
    *No user is logged in on DOITTECH-227-6
    PS > Rename-DSAComputer -ComputerName DOITTECH-227-6 -NewComputerName DOITTECH-227-7

    Invoking command to rename computer DOITTECH-227-6 to DOITTECH-227-7... done

.EXAMPLE
    *A user is logged in on DOITTECH-227-6
    PS > Rename-DSAComputer -ComputerName DOITTECH-227-6 -NewComputerName DOITTECH-227-7

    User is currently logged in on DOITTECH-227-6. Try running again with -Force

.EXAMPLE
    *A user is logged in on DOITTECH-227-6 with Force
    PS > Rename-DSAComputer -ComputerName DOITTECH-227-6 -NewComputerName DOITTECH-227-7 -Force

    Invoking command to rename computer DOITTECH-227-6 to DOITTECH-227-7... done

.NOTES

Author: Jacob Donais
Version: v1.2
Change Log:
    v1.0
        Initial build
    v1.1
        Added examples
    v1.2
        Adjusted restart functionality
#>

Function Rename-DSAComputer {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter an existing computer name")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Test-Connection $_ -Quiet -Count 1) -and
                         ($env:COMPUTERNAME -ne $_)})]
        [String]$ComputerName,
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter the new computer name")]
        [ValidateNotNullOrEmpty()]
        [String]$NewComputerName,
        [Int]$Timeout=60,
        [Switch]$Force
    )

    PROCESS {
        if ([string]::IsNullOrEmpty((Get-DSALoggedOnUser -ComputerName $ComputerName).USERNAME) -or $Force) {
            Write-Host "Invoking command to rename computer $ComputerName to $NewComputerName... " -NoNewline
            try {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                    Param(
                        $NewComputerName,
                        $Timeout
                    )
                    Rename-Computer -NewName $NewComputerName -Force -DomainCredential "dsa\" -WarningAction Ignore -ErrorAction Stop
                    shutdown /r /t $Timeout
                } -ArgumentList $NewComputerName,$Timeout
                Write-Host "done" -ForegroundColor Yellow
            }
            catch {
                Write-Host "failed" -ForegroundColor Red
            }
        }
        else {
            Write-Host "User is currently logged in on $ComputerName. Try running again with -Force" -ForegroundColor Red
        }
    }
}
