<#
.SYNOPSIS
    Returns the logged on users for given workstation(s)

.DESCRIPTION
    The Get-LoggedOnUser cmdlet gets information about user session on a device. You can use this command to find out if a specific user
    is logged in physically, remotely, or is disconnected/inactive.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
    v1.1
        Adjusted return on no users logged in to return an empty object.
#>

Function Get-LoggedOnUser {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$true, 
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter a computer name")]
        [Alias('ComputerName', 'CN')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Connection $_ -Quiet -Count 1})]
        [String[]]$Name
    )

    Process {
        foreach ($N in $Name) {
            Write-Progress -Id 0 "Collecting user info on $N"
            try {
                Invoke-Command -ComputerName $N -ScriptBlock {quser | ForEach-Object -Process { $_ -replace '\s{2,}',',' } | ConvertFrom-Csv} -ErrorAction Stop
            }
            catch {
                New-Object psobject -Property @{
                    USERNAME = ""
                    SESSIONNAME = ""
                    ID = ""
                    STATE = ""
                    "IDLE TIME" = ""
                    "LOGON TIME" = ""
                    PSComputerName = $N
                    RunspaceId = ""
                }
            }
        }
    }
}
