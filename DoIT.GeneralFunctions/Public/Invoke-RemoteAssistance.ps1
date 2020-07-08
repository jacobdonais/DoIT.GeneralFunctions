<#
.SYNOPSIS
    Provide remote assistance with either a computer name or IP address

.DESCRIPTION
    The Invoke-RemoteAssistance function will determine if a computer is online and will attempt to startup
    Microsoft Remote Assistance with it.

.EXAMPLE
    PS > Invoke-RemoteAssistance -ComputerName DOITTECH-227-6

    Attempting to provide remote assistance...
     ComputerName = DOITTECH-227-6
     Active User = jacobd
    Press any key to continue or CTRL+C to quit:
    Please continue with Microsoft Windows Remote Assistance UI

.NOTES

Author: Jacob Donais
Version: v1.3
Change Log:
    v1.0
        Initial build
    v1.1
        Updated output text
    v1.2
        Added Example
    v1.3
        Added Press any key to continue
#>

Function Invoke-RemoteAssistance {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory = $true, 
            HelpMessage = "Enter a computer name")]
        [Alias('CN', 'IPAddress')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $env:COMPUTERNAME -ne $_ })]
        [String]$ComputerName,
        [Switch]$Force
    )

    PROCESS {
        Write-Host "Attempting to provide remote assistance..."

        if ($Force) {
            msra /offerRA $ComputerName
        }
        else {
            if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
                Write-Host " ComputerName = " -NoNewline
                Write-Host "$ComputerName" -ForegroundColor Yellow

                do {
                    $User = Get-DSALoggedOnUser -Name $ComputerName | Where-Object { $_.STATE -eq "Active" }

                    if ($User) {
                        Write-Host " Active User = " -NoNewline
                        Write-Host "$($User.UserName)" -ForegroundColor Yellow
                        Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
                        msra /offerRA $ComputerName
                        Write-Host "Please continue with Microsoft Windows Remote Assistance UI"
                    }
                    else {
                        Write-Host "no user is logged in; press ctrl+c to stop attempting to connect" -ForegroundColor Red
                    }
                    Start-Sleep -Seconds 5
                } while (-not $User)
            }
            else {
                Write-Host "$ComputerName is either offline or Hostname IP mapping is incorrect" -ForegroundColor Red
            }
        }
    }
}
