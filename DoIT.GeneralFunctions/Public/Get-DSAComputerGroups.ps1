<#
.SYNOPSIS
    Queries a given AD computer for their security groups and copies to clipboard

.DESCRIPTION
    The Get-ComputerGroups cmdlet will return the groups for a given computer. If the
    computer exists in AD then it will set it to the clipboard.

.EXAMPLE
    PS > Get-DSAComputerGroups -Name doittech-227-6

    Collecting groups for doittech-227-6...
    Domain Computers
    DoIT Service Desk Technician Computers

.EXAMPLE
    PS > Get-DSAComputerGroups -Name doittech-227-6 -Clipboard

    Collecting groups for doittech-227-6...
    Domain Computers
    DoIT Service Desk Technician Computers


.EXAMPLE
    PS > Get-DSAComputerGroups -Name doittech-227-6,doittech-227-5

    Collecting groups for doittech-227-6...
    Domain Computers
    DoIT Service Desk Technician Computers
    Collecting groups for doittech-227-5...
    Domain Computers
    DoIT Service Desk Technician Computers

.EXAMPLE
    PS > Get-DSAComputerGroups -Name doittech-227-6,doittech-227-5 -Clipboard

    Collecting groups for doittech-227-6...
    Domain Computers
    DoIT Service Desk Technician Computers
    Collecting groups for doittech-227-5...
    Domain Computers
    DoIT Service Desk Technician Computers

.EXAMPLE
    Please keep in mind of how Powershell processes piping, so the Clipboard parameter will not work as intended.
    PS > Get-ADComputer -Filter "name -like 'DOITTECH-227*'" | Get-DSAComputerGroups

    Collecting groups for DOITTECH-227-1...
    Domain Computers
    DoIT Service Desk Technician Computers
    Collecting groups for DOITTECH-227-2...
    Domain Computers
    DoIT Service Desk Technician Computers
    Collecting groups for DOITTECH-227-3...
    Domain Computers
    DoIT Service Desk Technician Computers
    Collecting groups for DOITTECH-227-4...
    Domain Computers
    DoIT Service Desk Technician Computers
    Collecting groups for DOITTECH-227-5...
    Domain Computers
    DoIT Service Desk Technician Computers
    Collecting groups for DOITTECH-227-6...
    Domain Computers
    DoIT Service Desk Technician Computers

.INPUTS
    String[]

    A computer object that was retrieved by using the Get-ADComputer cmdlet and then modified is received by the Instance parameter.

.OUTPUTS
    Nothing

.NOTES

Author: Jacob Donais
Version: v1.2
Change Log:
    v1.0
        Initial build
    v1.1
        Added Examples
    v1.2
        Impoved documentation
        Set default computer name to $env:COMPUTERNAME

#>

Function Get-DSAComputerGroups {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter a computer name")]
        [Alias('ComputerName', 'CN')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADComputer -Filter "name -eq '$_'") -ne $null})]
        [String[]]$Name = $env:COMPUTERNAME
    )

    PROCESS {
        foreach ($C in $Name) {
            Write-Host "$C"
            Write-Host $('-' * ($C.length))
            $ComputerGroups = Get-ADComputer -Filter "name -eq '$C'"| Get-ADPrincipalGroupMembership
            foreach ($Group in $ComputerGroups.name) {
                Write-Host "$Group"
            }
        }
    }
}
