<#
.SYNOPSIS
    Gets the number of monitors connected to a workstation.

.DESCRIPTION
    The Get-MonitorCount cmdlet returns the number of monitors attached to a remote
    desktop.

.EXAMPLE
    PS > Get-MonitorCount

    ComputerName   MonitorCount
    ------------   ------------
    DOITTECH-227-6           2

.EXAMPLE
    PS > Get-MonitorCount -Name "DOITTECH-227-5","DOITTECH-227-4"

    ComputerName   MonitorCount
    ------------   ------------
    DOITTECH-227-5            2
    DOITTECH-227-4            2


.EXAMPLE
    PS > Get-ADComputer -Filter "name -like 'DOITTECH-227*'" | Get-MonitorCount

    ComputerName   MonitorCount
    ------------   ------------
    DOITTECH-227-1            2
    DOITTECH-227-2            2
    DOITTECH-227-3            2
    DOITTECH-227-4            2
    DOITTECH-227-5            2
    DOITTECH-227-6            2

.INPUTS
    String[]

    A computer object that was retrieved by using the Get-ADComputer cmdlet and then modified is received by the Instance parameter.

.OUTPUTS
    PSCustomObject

.NOTES

Author: Jacob Donais
Version: v1.3
Change Log:
    v1.0
        Initial build
    v1.1
        Added pipeline feature from Get-ADComputer to this
    v1.2
        Added Examples
    v1.3
        Impoved documentation
        Set default computer name to $env:COMPUTERNAME

#>

Function Get-MonitorCount {
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
        foreach ($C in $Name) {
            if ($C -eq $env:COMPUTERNAME) {
                New-Object psobject -Property ([ordered]@{
                    ComputerName = $C
                    MonitorCount = (Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams | where {$_.Active -like "True"}).Active.Count
                })
            }
            else {
                New-Object psobject -Property ([ordered]@{
                    ComputerName = $C
                    MonitorCount = (Get-CimInstance -ComputerName $C -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams | where {$_.Active -like "True"}).Active.Count
                })
            }
        }
    }
}
