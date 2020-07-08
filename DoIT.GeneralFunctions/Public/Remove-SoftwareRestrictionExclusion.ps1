<#
.SYNOPSIS
    Removes a computer from the software exclusions list.

.DESCRIPTION
    The Remove-SoftwareRestrictionExclusion cmdlet removes a computer from the exclusions list.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
    v1.1
        Added error checking in case the security group name changes
#>

Function Remove-SoftwareRestrictionExclusion {
    [CmdletBinding()]Param (
        [Parameter (Mandatory = $true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADComputer -Filter "name -eq '$_'") -ne $null})]
        [String]$ComputerName
    )

    Process {
        $SWExclusionName = "DoIT Software Restriction Policy Computer Exclusions"
        $SWExclusionGroup = Get-ADGroup -Filter "name -eq '$SWExclusionName'"

        if ($SWExclusionGroup -eq $null) {
             Write-Host "0x00000001 Please contact script manager" -ForegroundColor Red
             break
        }

        Write-Host "Removing $ComputerName from 'DoIT Software Restriction Policy Computer Exclusions' group... " -ForegroundColor Yellow -NoNewline
        try {
            $SWExclusionGroup | Remove-ADGroupMember -Members (Get-ADComputer -Filter "name -eq '$ComputerName'") -ErrorAction Stop
            Write-Host "done"
        }
        catch {
            Write-Host "failed; check if you have permissions to edit $ComputerName or $SWExclusionName." -ForegroundColor Red
        }
    }
}
