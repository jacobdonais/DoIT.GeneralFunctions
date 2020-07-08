<#
.SYNOPSIS
    Removes the hostname from the Hosts file.

.DESCRIPTION
    The Remove-Host cmdlet removes the hostname from the Hosts file.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
    v1.1
        Improved RegEx compare to find and delete.
#>

Function Remove-Host {
    [CmdletBinding()]Param (
            [Parameter(
                Mandatory=$true,
                HelpMessage="Enter an IP address")]
            [ValidateNotNullOrEmpty()]
            [String]$HostName
        )

    Process {
        $Path = "$env:windir\System32\drivers\etc\hosts"
        $Pattern = '^(?<IP>\d{1,3}(\.\d{1,3}){3})\s+(' + $HostName + ')$'
        $Entries = @()

        Write-Host "About to remove $HostName from hosts file..."

        try {
            (Get-Content -Path $Path)  | ForEach-Object {
                if ($_ -notmatch $Pattern) {
                    $Entries += $_
                }
                else {
                    Write-Host "$($Matches.IP) `t $HostName - removing from hosts file..." -ForegroundColor Yellow
                }
            }
            Write-Host "Saving changes... " -NoNewline
            $Entries | Out-File $Path
            Write-Host "done"
        }
        catch {
            Write-Host "failed; please try running as an admin or check file permissions for $Path" -ForegroundColor Red
        }
    }
}
