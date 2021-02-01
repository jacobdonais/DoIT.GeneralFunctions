<#
.SYNOPSIS
    Returns the mapped hostname to IP address.

.DESCRIPTION
    The Get-Hosts function gets the human-friendly hostnames to numerical Internet Protocol (IP) addresses mapping.

.INPUTS
    None

.OUTPUTS
    PSCustomObject

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
    v1.1
        Added try/catch block in case the user does not have read permission on the hosts file.
        Adjusted output to be more clear.
    v1.2
        Return object

#>

Function Get-Hosts {
    [CmdletBinding()]Param (
        )

    PROCESS {
        $Path = "$env:windir\System32\drivers\etc\hosts"
        $Pattern = '^(?<IP>\d{1,3}(\.\d{1,3}){3})\s+(?<Host>.+)$'
        $Entries = @()

        try {
            (Get-Content -Path $Path)  | ForEach-Object {
                if ($_ -match $Pattern) {
                    $Entries += New-Object psobject -Property ([ordered]@{
                        HostName = $Matches.Host
                        DesiredIP = $Matches.IP
                    })
                }
            }
            $Entries
        }
        catch {
            Write-Host "unable to read hosts file" -ForegroundColor Red
        }
    }
}
