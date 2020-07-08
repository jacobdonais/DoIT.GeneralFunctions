<#
.SYNOPSIS
    Provide remote assistance with either a computer name or IP address

.DESCRIPTION
    The Invoke-RemoteAssistance cmdlet will determine if a computer is online and will attempt to startup
    Microsoft Remote Assistance with it.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
#>

Function Invoke-RemoteAssistance {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$true, 
            HelpMessage="Enter a computer name")]
        [Alias('CN', 'IPAddress')]
        [ValidateNotNullOrEmpty()]
        [String]$ComputerName
    )

    Process {
        Write-Host "Attempting to provide remote assistance to $ComputerName... " -NoNewline
        if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
            msra /offerRA $ComputerName
            Write-Host "done"
        }
        else {
            Write-Host "failed" -ForegroundColor Red
            Write-Host "Either Remote Assistance is unable to find the remote computer or you do not have permission to connect to the remote computer. Verify that the computer name and permissions are correct, and then try again."
        }
    }
}