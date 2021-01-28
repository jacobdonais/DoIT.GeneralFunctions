<#
.SYNOPSIS
    This will return the size and free space on a computer.

.DESCRIPTION
    The Get-DiskSpace cmdlet will provide the total space on a hard drive and the freespace.

.EXAMPLE
    PS > Get-DiskSpace -Name DOITTECH-227-6

    ComputerName   DriverLetter        Size (GB)   FreeSpace (GB)
    ------------   ------------        ---------   --------------
    DOITTECH-227-6 C:            236.77271270752 174.897327423096
    DOITTECH-227-6 M:           449.998043060303 42.8125762939453
    DOITTECH-227-6 O:           449.998043060303 42.8125762939453
    DOITTECH-227-6 U:           449.998043060303 42.8125762939453
    DOITTECH-227-6 V:           49.6562461853027   29.21337890625
    DOITTECH-227-6 X:            1609.9970664978 234.672637939453

.EXAMPLE
    PS > Get-DiskSpace -Name "DOITTECH-227-6","DOITTECH-227-5"

    ComputerName   DriverLetter        Size (GB)   FreeSpace (GB)
    ------------   ------------        ---------   --------------
    DOITTECH-227-6 C:            236.77271270752  174.89644241333
    DOITTECH-227-6 M:           449.998043060303 42.8125762939453
    DOITTECH-227-6 O:           449.998043060303 42.8125762939453
    DOITTECH-227-6 U:           449.998043060303 42.8125762939453
    DOITTECH-227-6 V:           49.6562461853027   29.21337890625
    DOITTECH-227-6 X:            1609.9970664978 234.672637939453
    DOITTECH-227-5 C:           237.019554138184 121.864688873291

.EXAMPLE
    PS > Get-ADComputer -Filter "name -like 'DOITTECH-227*'" | Get-DiskSpace

    ComputerName   DriverLetter        Size (GB)   FreeSpace (GB)
    ------------   ------------        ---------   --------------
    DOITTECH-227-1 C:           237.014789581299 109.567054748535
    DOITTECH-227-2 C:           237.014324188232 118.279098510742
    DOITTECH-227-3 C:           236.777393341064 173.367660522461
    DOITTECH-227-4 C:           237.019115447998  127.71643447876
    DOITTECH-227-5 C:           237.019554138184 121.864688873291
    DOITTECH-227-6 C:            236.77271270752 174.896305084229
    DOITTECH-227-6 M:           449.998043060303 42.8125762939453
    DOITTECH-227-6 O:           449.998043060303 42.8125762939453
    DOITTECH-227-6 U:           449.998043060303 42.8125762939453
    DOITTECH-227-6 V:           49.6562461853027   29.21337890625
    DOITTECH-227-6 X:            1609.9970664978 234.672637939453

.INPUTS
    String[]

    A computer object that was retrieved by using the Get-ADComputer cmdlet and then modified is received by the Instance parameter.

.OUTPUTS
    PSCustomObject

.NOTES

Author: Jacob Donais
Version: v1.2
Change Log:
    v1.0
        Initial build
    v1.1
        Added Examples for standard, array, and pipeline
    v1.2
        Impoved documentation
        Set default computer name to $env:COMPUTERNAME

#>

Function Get-DiskSpace {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter a computer name")]
        [Alias('ComputerName', 'CN')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Test-Connection $_ -Quiet -Count 1)})]
        [String[]]$Name = $env:COMPUTERNAME
    )

    PROCESS {
        foreach ($C in $Name) {
            if ($C -eq $env:COMPUTERNAME) {
                $LogicalDisk = Get-CimInstance Win32_LogicalDisk | Where-Object {$_.Size -ne $null}
            }
            else {
                $LogicalDisk = Get-CimInstance Win32_LogicalDisk -ComputerName $C | Where-Object {$_.Size -ne $null}
            }
            foreach ($Disk in $LogicalDisk) {
                New-Object psobject -Property ([ordered]@{
                    ComputerName = $C
                    DriverLetter = $Disk.Name
                    "Size (GB)" = $Disk.Size/1GB
                    "FreeSpace (GB)" = $Disk.FreeSpace/1GB
                })
            }
        }
    }
}
