<#
.SYNOPSIS
    Returns basic information about monitors

.DESCRIPTION
    The Get-MonitorInfo cmdlet returns the manufacturer, name, and serial number
    of the monitors connected to a computer.

.EXAMPLE
    PS > Get-MonitorInfo -Name DOITTECH-227-6

    ComputerName   Manufacturer Name  Serial    
    ------------   ------------ ----  ------    
    DOITTECH-227-6 HN           H E73 CNK91505LV
    DOITTECH-227-6 HN           H E73 CNK91811TX

.EXAMPLE
    PS > Get-MonitorInfo -Name DOITTECH-227-6,DOITTECH-227-5

    ComputerName   Manufacturer Name  Serial    
    ------------   ------------ ----  ------    
    DOITTECH-227-6 HN           H E73 CNK91505LV
    DOITTECH-227-6 HN           H E73 CNK91811TX
    DOITTECH-227-5 HN           H E73 CNK918189H
    DOITTECH-227-5 HN           H E73 CNK91505MB

.EXAMPLE
    PS > Get-ADComputer -Filter "name -like 'DOITTECH-227*'" | Get-MonitorInfo

    ComputerName   Manufacturer Name  Serial    
    ------------   ------------ ----  ------    
    DOITTECH-227-1 HN           H E73 CNK915059B
    DOITTECH-227-1 HN           H E73 CNK91505M7
    DOITTECH-227-2 HN           H E73 CNK91811VS
    DOITTECH-227-2 HN           H E73 CNK91811VW
    DOITTECH-227-3 HN           H E73 CNK91811VX
    DOITTECH-227-3 HN           H E73 CNK918189J
    DOITTECH-227-4 HN           H E73 CNK918189G
    DOITTECH-227-4 HN           H E73 CNK91811VV
    DOITTECH-227-5 HN           H E73 CNK918189H
    DOITTECH-227-5 HN           H E73 CNK91505MB
    DOITTECH-227-6 HN           H E73 CNK91505LV
    DOITTECH-227-6 HN           H E73 CNK91811TX

.INPUTS
    String[]

    A computer object that was retrieved by using the Get-ADComputer cmdlet and then modified is received by the Instance parameter.

.OUTPUTS
    PSCustomObject

.NOTES

Author: Jacob Donais
Version: v1.1
Change Log:
    v1.0
        Initial build
    v1.1
        Impoved documentation
        Set default computer name to $env:COMPUTERNAME

#>

Function Get-MonitorInfo {
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
            if ($env:COMPUTERNAME -eq $C) {
                $Monitors = Get-WmiObject WmiMonitorID -Namespace root\wmi
            }
            else {
                $Monitors = Invoke-Command -ComputerName $C -ScriptBlock { Get-WmiObject WmiMonitorID -Namespace root\wmi }
            }

            foreach ($Monitor in $Monitors) {
                New-Object psobject -Property ([ordered]@{
                    ComputerName = $C
                    Manufacturer = ($Monitor.ManufacturerName -notmatch 0 | ForEach{[char]$_}) -join ""
                    Name = ($Monitor.UserFriendlyName -notmatch 0 | ForEach{[char]$_}) -join ""
                    Serial = ($Monitor.SerialNumberID -notmatch 0 | ForEach{[char]$_}) -join ""
                })
            }
        }
    }
}
