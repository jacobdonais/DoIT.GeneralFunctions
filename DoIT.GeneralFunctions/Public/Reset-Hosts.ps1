<#
.SYNOPSIS
    Resets the Hosts file to the default.

.DESCRIPTION
    The Reset-Hosts cmdlet resets the Hosts file back to the default

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
    v1.1
        Added error checking on file permissions for default hosts file and hosts file.
#>

Function Reset-Hosts {
    [CmdletBinding()]Param (
        )

    Process {
        $Path = "$env:windir\System32\drivers\etc\hosts"
        $DefaultHostsPath = "$PSScriptRoot\..\Resources\Hosts\DefaultHosts"

        Write-Host "About to reset Hosts file to default... " -NoNewline
        try {
            $defaultHost = Get-Content -Path $DefaultHostsPath
        }
        catch {
            Write-Host "ERROR: 0x00000002 Please contact script manager" -ForegroundColor Red
            break
        }

        try {
            $defaultHost | Out-File $Path
            Write-Host "done"
        }
        catch {
            Write-Host "failed; please try running as an admin or check file permissions for $Path" -ForegroundColor Red
        }
        
    }
}
