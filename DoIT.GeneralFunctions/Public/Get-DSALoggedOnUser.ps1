<#
.SYNOPSIS
    Returns the logged on users for given workstation(s)

.DESCRIPTION
    The Get-DSALoggedOnUser cmdlet gets information about user session on a device. You can use this command to find out if a specific user
    is logged in physically, remotely, or is disconnected/inactive.

.EXAMPLE
    PS > Get-DSALoggedOnUser -Name DOITTECH-227-6

    Username       : jacobd
    SessionName    : rdp-tcp#9
    ID             : 2
    State          : Active
    IdleTime       : .
    LogonTime      : 9/28/2020 7:56:00 AM
    PSComputerName : DOITTECH-227-6

.EXAMPLE
    PS > Get-DSALoggedOnUser -Name DOITTECH-227-6,DOITTECH-227-5

    Username       : jacobd
    SessionName    : rdp-tcp#9
    ID             : 2
    State          : Active
    IdleTime       : .
    LogonTime      : 9/28/2020 7:56:00 AM
    PSComputerName : DOITTECH-227-6

    Username       : robertk
    SessionName    : console
    ID             : 20
    State          : Active
    IdleTime       : none
    LogonTime      : 9/28/2020 8:20:00 AM
    PSComputerName : DOITTECH-227-5

.EXAMPLE
    PS > Get-ADComputer -Filter "name -like 'DOITTECH-227*'" | Get-DSALoggedOnUser

    Username       : 
    SessionName    : 
    ID             : 
    State          : 
    IdleTime       : 
    LogonTime      : 
    PSComputerName : DOITTECH-227-1

    Username       : andrewh
    SessionName    : rdp-tcp#1
    ID             : 2
    State          : Active
    IdleTime       : .
    LogonTime      : 9/28/2020 10:07:00 AM
    PSComputerName : DOITTECH-227-2

    Username       : 
    SessionName    : 
    ID             : 
    State          : 
    IdleTime       : 
    LogonTime      : 
    PSComputerName : DOITTECH-227-3

    Username       : 
    SessionName    : 
    ID             : 
    State          : 
    IdleTime       : 
    LogonTime      : 
    PSComputerName : DOITTECH-227-4

    Username       : robertk
    SessionName    : console
    ID             : 20
    State          : Active
    IdleTime       : none
    LogonTime      : 9/28/2020 8:20:00 AM
    PSComputerName : DOITTECH-227-5

    Username       : jacobd
    SessionName    : rdp-tcp#9
    ID             : 2
    State          : Active
    IdleTime       : .
    LogonTime      : 9/28/2020 7:56:00 AM
    PSComputerName : DOITTECH-227-6

.EXAMPLE
    PS > Get-ADComputer -Filter "name -like 'doittech*'" | Get-DSALoggedOnUser | Where-Object {$_.State -ne ""}

    Username       : andrewh
    SessionName    : rdp-tcp#1
    ID             : 2
    State          : Active
    IdleTime       : 1
    LogonTime      : 9/28/2020 10:07:00 AM
    PSComputerName : DOITTECH-227-2

    Username       : robertk
    SessionName    : console
    ID             : 20
    State          : Active
    IdleTime       : none
    LogonTime      : 9/28/2020 8:20:00 AM
    PSComputerName : DOITTECH-227-5

    Username       : jacobd
    SessionName    : rdp-tcp#9
    ID             : 2
    State          : Active
    IdleTime       : .
    LogonTime      : 9/28/2020 7:56:00 AM
    PSComputerName : DOITTECH-227-6

.INPUTS
    String[]

    A computer object that was retrieved by using the Get-ADComputer cmdlet and then modified is received by the Instance parameter.

.OUTPUTS
    PSCustomObject

.NOTES

Author: Jacob Donais
Version: v1.5
Change Log:
    v1.0
        Initial build
    v1.1
        Adjusted return on no users logged in to return an empty object.
    v1.2
        Object returned is not accurate. Removed inaccurate line
        Invoke-Command -ComputerName $N -ScriptBlock {quser | ForEach-Object -Process { $_ -replace '\s{2,}',',' } | ConvertFrom-Csv} -ErrorAction Stop
    v1.3
        Renamed cmdlet
    v1.4
        Added Examples for standard, array, and pipeline.
    v1.5
        Impoved documentation
        Set default computer name to $env:COMPUTERNAME

#>

Function Get-DSALoggedOnUser {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$false, 
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter a computer name")]
        [Alias('ComputerName', 'CN')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Connection $_ -Quiet -Count 1})]
        [String[]]$Name = $env:COMPUTERNAME
    )

    PROCESS {
        foreach ($N in $Name) {
            Write-Progress -Id 0 "Collecting user info on $N"
            try {
                if ($env:COMPUTERNAME -eq $N) {
                    $stringOutput = quser
                }
                else {
                    $stringOutput = Invoke-Command -ComputerName $N -ScriptBlock { quser } -ErrorAction Stop
                }

                foreach ($line in $stringOutput) {
                    if ($line -match "logon time") {
                        Continue
                    }

		            New-Object psobject -Property ([ordered]@{
                        Username = $line.SubString(1, 20).Trim()
			            SessionName = $line.SubString(23, 17).Trim()
			            ID = $line.SubString(42, 2).Trim()
			            State = $line.SubString(46, 6).Trim()
			            IdleTime = $idleStringValue = $line.SubString(54, 9).Trim()
			            LogonTime = [datetime]$line.SubString(65)
                        PSComputerName = $N
		            })
                }
            }
            catch {
                New-Object psobject -Property ([ordered]@{
                    Username = ""
                    SessionName = ""
                    ID = ""
                    State = ""
                    IdleTime = ""
                    LogonTime = ""
                    PSComputerName = $N
                })
            }
        }
    }
}
