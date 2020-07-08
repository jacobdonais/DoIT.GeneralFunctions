<#
.SYNOPSIS
    Resets the Hosts file to the default.

.DESCRIPTION
    The Reset-Hosts function resets the Hosts file back to the default

.INPUTS
    None

.OUTPUTS
    None

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

    BEGIN {
        Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
        $Path = "$env:windir\System32\drivers\etc\hosts"
        $DefaultHostsPath = "$PSScriptRoot\..\Resources\Hosts\DefaultHosts"
    }

    PROCESS {
        Write-Host "About to reset Hosts file to default... " -NoNewline
        try {
            $defaultHost = Get-Content -Path $DefaultHostsPath
        }
        catch {
            Write-Host "failed; unable to read the default hosts file" -ForegroundColor Red
            break
        }

        try {
            $defaultHost | Out-File $Path
            Write-Host "done"
        }
        catch {
            Write-Host "failed; unable to write to hosts file" -ForegroundColor Red
        }
        
    }
}
