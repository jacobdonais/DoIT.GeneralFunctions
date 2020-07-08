<#
.SYNOPSIS
    Gets the number of monitors connected to a workstation.

.DESCRIPTION
    The Get-MonitorCount cmdlet returns the number of monitors attached to a remote
    desktop.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
#>

Function Get-MonitorCount {
    [CmdletBinding()]Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Connection $_ -Quiet -Count 1})]
        [String]$ComputerName
    )

    Process {
        New-Object psobject -Property @{
            MonitorCount = (Get-CimInstance -ComputerName $ComputerName -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams | where {$_.Active -like "True"}).Active.Count
            ComputerName = $ComputerName
        }
    }
}
