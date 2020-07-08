<#
.SYNOPSIS
    Returns computer name by MAC address

.DESCRIPTION
    The Search-SCCMComputerByMAC function will return computer name(s) by
    the mac address.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build

#>

Function Search-SCCMComputerByMAC {
    [CmdletBinding()]Param(
        [Parameter(
            Mandatory = $true, 
            ValueFromPipeline = $true,
            HelpMessage = "Enter a MAC address")]
        [ValidateNotNullOrEmpty()]
        [String[]]$MAC
    )

    BEGIN {
        try {
            $SiteDrive = Get-PSDrive -PSProvider CMSite -ErrorAction Stop
            if ($SiteDrive -and $SiteDrive.count -eq 1) {
                Push-Location "$($SiteDrive.Name):"
            }
            else {
                Write-Error "Failed to find CMSite or returned too many." -ErrorAction Stop
                exit
            }
        }
        catch {
            Write-Error "Please run Powershell with admin account and run Enter-ConfigurationManager." -ErrorAction Stop
            exit
        }
    }

    PROCESS {
        $ret = @()

        foreach ($val in $MAC) {
            $val = $val.replace("-", ":").replace("\^", ":").replace("\.", ":")
            $ComputerName = (Get-CMResource -ResourceType System -Fast | Where-Object { $_.MACAddresses -eq $val }).name

            $ret += New-Object pscustomobject -Property ([ordered]@{
                    ComputerName = $ComputerName
                    MAC          = $val
                })
        }

        return $ret
    }

    END {
        Pop-Location
    }
}
