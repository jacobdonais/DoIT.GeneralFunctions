<#
.SYNOPSIS
    Checks if a computer has a fan error

.DESCRIPTION
    This script will check if a given computer has a fan error and will return
    the serial number, computer name, and model name.

.EXAMPLE
    PS > Test-ComputerFanError -Name DOITTECH-227-6

    ComputerName   Model                   SerialNumber FanError
    ------------   -----                   ------------ --------
    DOITTECH-227-6 HP EliteDesk 800 G3 SFF 2UA80923HV      False

.EXAMPLE
    PS > Get-ADComputer -Filter "name -like 'RECSREC*'" | Test-ComputerConnection | Where-Object {$_.Online -eq $true} | Test-ComputerFanError

    ComputerName    Model                   SerialNumber FanError
    ------------    -----                   ------------ --------
    RECSREC-101-EC  HP EliteDesk 800 G2 SFF MXL6503X3W      False
    RECSREC-101-EC2 HP EliteDesk 800 G2 SFF MXL6503X5C      False
    RECSREC-101-EE0 HP EliteDesk 800 G2 SFF MXL6503X3K      False
    RECSREC-101-MS0 HP EliteDesk 800 G2 SFF MXL6503X3D      False
    RECSREC-101-MS1 HP EliteDesk 800 G2 SFF MXL6503X3X      False
    RECSREC-1118-2  HP EliteDesk 800 G2 SFF MXL65042DR      False
    RECSREC-1118-3  HP EliteDesk 800 G2 SFF MXL6503X3T       True
    RECSREC-1118G-0 HP EliteDesk 800 G2 SFF MXL6503X3L      False
    RECSREC-114-0   HP EliteDesk 800 G2 SFF MXL6503X3H      False
    RECSREC-114-1   HP EliteDesk 800 G2 SFF MXL6503X4H      False
    RECSREC-114-2   HP EliteDesk 800 G2 SFF MXL6503X43      False
    RECSREC-114-3   HP EliteDesk 800 G2 SFF MXL6503X57      False
    RECSREC-1140-0  HP EliteDesk 800 G2 SFF MXL65042DN       True
    ...

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
        Added examples
    v1.3
        Impoved documentation
        Set default computer name to $env:COMPUTERNAME

#>

Function Test-ComputerFanError {
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
            Write-Progress -Id 0 "Collecting Computer Fan info on $C"

            $computerObj = New-Object psobject -Property ([ordered]@{
                ComputerName = "$C"
                Model = ""
                SerialNumber = ""
                FanError = $false
            })

            if ($C -eq $env:COMPUTERNAME) {
                $computerObj.Model = (Get-CimInstance -ClassName win32_computersystem).Model
                $computerObj.SerialNumber = (Get-CimInstance -Class win32_BIOS).SerialNumber
                $fans = Get-CimInstance -ClassName win32_fan
            }
            else {
                $computerObj.Model = (Get-CimInstance -ComputerName $C -ClassName win32_computersystem).Model
                $computerObj.SerialNumber = (Get-CimInstance -ComputerName $C -Class win32_BIOS).SerialNumber
                $fans = Get-CimInstance -ComputerName $C -ClassName win32_fan
            }

            $fans | ForEach-Object {
                if ($_.status -ne "OK") {
                    $computerObj.FanError = $true
                }
            }

            $computerObj
        }
    }
}
