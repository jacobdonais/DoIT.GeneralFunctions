<#
.SYNOPSIS
    Checks if a computer has a fan error

.DESCRIPTION
    This script will check if a given computer has a fan error and will return
    the serial number, computer name, and model name.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
#>

Function Test-ComputerFanError {
    [CmdletBinding()]Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Connection $_ -Quiet -Count 1})]
        [String[]]$ComputerName
    )

    Process {
        foreach ($C in $ComputerName) {
            Write-Progress -Id 0 "Collecting Computer Fan info on $C"
            $computerObj = New-Object psobject -Property @{
                    ComputerName = "$C"
                    SerialNumber = (Get-CimInstance  -ComputerName $C -Class win32_BIOS).SerialNumber
                    Model = (Get-CimInstance -ComputerName $C -ClassName win32_computersystem).Model
                    FanError = $false
                }

            Get-CimInstance -ComputerName $C -ClassName win32_fan | ForEach-Object {
                if ($_.status -ne "OK") {
                    $computerObj.FanError = $true
                }
            }
            $computerObj
        }
    }
}
