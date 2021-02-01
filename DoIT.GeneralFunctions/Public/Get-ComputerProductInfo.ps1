<#
.SYNOPSIS
    Gets serial number and model number of a computer

.DESCRIPTION
    The Get-ComputerProductInfo function gets the model and serial number
    of a remote device.

.EXAMPLE
    PS > Get-ComputerProductInfo -Name DOITTECH-227-6

    ComputerName : DOITTECH-227-6
    Model        : HP EliteDesk 800 G3 SFF
    SerialNumber : 2UA80923HV

.EXAMPLE
    PS > Get-ComputerProductInfo -Name "DOITTECH-227-6","DOITTECH-227-5"

    ComputerName : DOITTECH-227-6
    Model        : HP EliteDesk 800 G3 SFF
    SerialNumber : 2UA80923HV


    ComputerName : DOITTECH-227-5
    Model        : HP EliteDesk 800 G3 SFF
    SerialNumber : 2UA80923J0

.EXAMPLE
    PS > Get-ADComputer -Filter "name -like 'DOITTECH-227*'" | Get-ComputerProductInfo

    ComputerName : DOITTECH-227-1
    Model        : HP EliteDesk 800 G3 SFF
    SerialNumber : 2UA80923HX


    ComputerName : DOITTECH-227-2
    Model        : HP EliteDesk 800 G3 SFF
    SerialNumber : 2UA80923HW


    ComputerName : DOITTECH-227-3
    Model        : HP EliteDesk 800 G3 SFF
    SerialNumber : 2UA80923HY


    ComputerName : DOITTECH-227-4
    Model        : HP EliteDesk 800 G3 SFF
    SerialNumber : 2UA80923HZ


    ComputerName : DOITTECH-227-5
    Model        : HP EliteDesk 800 G3 SFF
    SerialNumber : 2UA80923J0


    ComputerName : DOITTECH-227-6
    Model        : HP EliteDesk 800 G3 SFF
    SerialNumber : 2UA80923HV

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
        Added examples for standard, array, and pipeline.
        Added validate test-connection
    v1.2
        Improved documentation for function.
        Set default computer name to $env:COMPUTERNAME

#>

Function Get-ComputerProductInfo {
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
                New-Object psobject -Property ([ordered]@{
                    ComputerName = "$C"
                    Model = (Get-CimInstance -ClassName win32_computersystem).Model
                    SerialNumber = (Get-CimInstance -Class win32_BIOS).SerialNumber
                }) | Format-List
            }
            else {
                New-Object psobject -Property ([ordered]@{
                    ComputerName = "$C"
                    Model = (Get-CimInstance -ComputerName $C -ClassName win32_computersystem).Model
                    SerialNumber = (Get-CimInstance -ComputerName $C -Class win32_BIOS).SerialNumber
                }) | Format-List
            }
        }
    }
}
