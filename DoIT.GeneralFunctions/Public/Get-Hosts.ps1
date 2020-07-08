<#
.SYNOPSIS
    Returns the mapped hostname to IP address.

.DESCRIPTION
    The Get-Hosts cmdlet gets the human-friendly hostnames to numerical Internet Protocol (IP) addresses mapping.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
    v1.1
        Added try/catch block in case the user does not have read permission on the hosts file.
        Adjusted output to be more clear.

#>

Function Get-Hosts {
    [CmdletBinding()]Param (
        )

    Process {
        $Path = "$env:windir\System32\drivers\etc\hosts"
        $Pattern = '^(?<IP>\d{1,3}(\.\d{1,3}){3})\s+(?<Host>.+)$'
        $Entries = @()

        Write-Host "Collecting Hosts file... " -NoNewline

        try {
            (Get-Content -Path $Path)  | ForEach-Object {
                if ($_ -match $Pattern) {
                    $Entries += "$($Matches.IP) `t $($Matches.Host)"
                }
            }
            Write-Host "done"
            $Entries
        }
        catch {
            Write-Host "failed; please try running as an admin or check file permissions for $Path" -ForegroundColor Red
        }
    }
}
