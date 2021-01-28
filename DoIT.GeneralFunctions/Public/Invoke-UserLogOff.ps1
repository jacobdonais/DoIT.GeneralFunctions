<#
.SYNOPSIS
    This cmdlet will logoff a user from a computer

.DESCRIPTION
    The Invoke-UserLogOff cmdlet will logoff a user from a workstation.

.EXAMPLE
    *jacobd state is not active
    PS > Invoke-UserLogOff -UserName jacobd -ComputerName doittech-227-6

    Attempting to logoff jacobd on doittech-227-6... done

.EXAMPLE
    *jacobd is active on doittech-227-6
    PS > Invoke-UserLogOff -UserName jacobd -ComputerName doittech-227-6

    Attempting to logoff jacobd on doittech-227-6... User is actively logged in; try with -force

.EXAMPLE
    *jacobd is active on doittech-227-6 with force
    PS > Invoke-UserLogOff -UserName jacobd -ComputerName doittech-227-6 -Force

    Attempting to logoff jacobd on doittech-227-6... done

.EXAMPLE
    *jacobd is not on doittech-227-6
    PS > Invoke-UserLogOff -UserName jacobd -ComputerName doittech-227-6

    Attempting to logoff jacobd on doittech-227-6... User is not logged in

.NOTES

Author: Jacob Donais
Version: v1.1
Change Log:
    v1.0
        Initial build
    v1.1
        Added examples

#>

Function Invoke-UserLogOff {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter a username")]
        [ValidateNotNullOrEmpty()]
        [String]$UserName,
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter a computername")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Connection $_ -Quiet -Count 1})]
        [Alias('PSComputerName', 'CN')]
        [String]$ComputerName,
        [Switch]$Force
    )

    PROCESS {
        Write-Host "Attempting to logoff $UserName on $ComputerName... " -NoNewline
        $User = Get-DSALoggedOnUser -ComputerName $ComputerName | Where-Object {$_.USERNAME -eq $UserName}

        if ($User) {
            if ($User.STATE -eq "ACTIVE" -and -not($Force)) {
                Write-Host "User is actively logged in; try with -force" -ForegroundColor Red
            }
            else {
                try {
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                        param($ID)
                        logoff $ID
                    } -ArgumentList ($User.ID)
                    Write-Host "done"
                }
                catch {
                    Write-Host "failed" -ForegroundColor Red
                }
            }
        }
        else {
            Write-Host "User is not logged in" -ForegroundColor Yellow
        }
    }
}
