<#
.SYNOPSIS
    Removes the hostname from the Hosts file.

.DESCRIPTION
    The Remove-Host cmdlet removes the hostname from the Hosts file.

.INPUTS
    String

.OUTPUTS
    None

.NOTES

Author: Jacob Donais
Version: v1.2
Change Log:
    v1.0
        Initial build
    v1.1
        Improved RegEx compare to find and delete.
    v1.2
        Accept pipeline
#>

Function Remove-Host {
    [CmdletBinding()]Param (
            [Parameter(
                Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                HelpMessage="Enter a host name")]
            [ValidateNotNullOrEmpty()]
            [String]$HostName
        )

    PROCESS {
        $Path = "$env:windir\System32\drivers\etc\hosts"
        $Pattern = '^(?<IP>\d{1,3}(\.\d{1,3}){3})\s+(' + $HostName + ')$'
        $Entries = @()

        try {
            (Get-Content -Path $Path)  | ForEach-Object {
                if ($_ -notmatch $Pattern) {
                    $Entries += $_
                }
                else {
                    Write-Verbose "$($Matches.IP) `t $HostName - removing from hosts file..."
                }
            }
        }
        catch {
            Write-Host "failed; unable to read the hosts file" -ForegroundColor Red
        }
        
        
        try {
            Write-Verbose "Saving changes... "
            $Entries | Out-File $Path
        }
        catch {
            Write-Host "failed; unable to write to hosts file" -ForegroundColor Red
        }
        
    }
}
