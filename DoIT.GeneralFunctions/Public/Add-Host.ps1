<#
.SYNOPSIS
    Adds the hostname from the Hosts file.

.DESCRIPTION
    This cmdlet will add a mapping of a hostname and a desired IP to the Window’s Hosts file. 
    This change only affects your own computer without affecting how the domain is resolved. 
    This particularly useful with the DNS record has been updated.

.INPUTS
    String

.OUTPUTS
    None

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
    v1.1
        Added try/catch block for add-content. This will remove the annoying error of
        when the user does not have permission to the Hosts file and will say it failed.
    v1.2
        Added regex compare to avoid rejecting a valid add. Such as:
        # 1.0.0.0 localhosts
        add-hosts localhosts 2.0.0.0
        would be rejected.
#>

Function Add-Host {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$true,
            HelpMessage="Enter a host name")]
        [ValidateNotNullOrEmpty()]
        [String]$HostName,
        [Parameter(
            Mandatory=$true,
            HelpMessage="Enter an IP address")]
        [ValidateNotNullOrEmpty()]
        [ipaddress]$DesiredIP
    )

    PROCESS {
        $Path = "$env:windir\System32\drivers\etc\hosts"
        $Pattern = '^(?<IP>\d{1,3}(\.\d{1,3}){3})\s+(' + $HostName + ')$'
        $entry = ([string]$DesiredIP + "`t" + $HostName)

        Write-Host "Attempting to add $Address for $HostName to hosts file..."
        Write-Host "$entry " -NoNewline -ForegroundColor Yellow

        if ((Get-Content -Path $Path) -match $Pattern) {
            Write-Host "- not adding; already in hosts file" -ForegroundColor Red
        }
        else {
            Write-Host "- adding to hosts file... " -NoNewline -ForegroundColor Yellow
            try {
                Add-Content -Value $entry -Path $Path -ErrorAction Stop
                Write-Host "done"
            }
            catch {
                Write-Host "failed; unable to write to hosts file" -ForegroundColor Red
            }
        }
    }
}
