<#
.SYNOPSIS
    Returns computer name by last logon user name

.DESCRIPTION
    The Search-SCCMComputerByLastLogonUserName function will return computer name(s) by
    the last logon user name.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build

#>

Function Search-SCCMComputerByLastLogonUserName {
    [CmdletBinding()]Param(
        [Parameter(
            Mandatory = $true, 
            ValueFromPipeline = $true,
            HelpMessage = "Enter a MAC address")]
        [ValidateNotNullOrEmpty()]
        [String[]]$Username
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

        foreach ($val in $username) {
            $ComputerName = (Get-CMResource -ResourceType System -Fast | Where-Object { $_.LastLogonUserName -eq $val }).name

            $ret += New-Object pscustomobject -Property ([ordered]@{
                    ComputerName = $ComputerName
                    Username     = $val
                })
        }

        return $ret
    }

    END {
        Pop-Location
    }
}
