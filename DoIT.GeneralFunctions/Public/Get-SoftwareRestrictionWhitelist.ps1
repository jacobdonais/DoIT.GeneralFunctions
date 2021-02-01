<#
.SYNOPSIS
    Will return a list of devices in the software restriction exclusion group.

.DESCRIPTION
    The Get-SoftwareRestrictionWhitelist function will return a list of
    devices in the software restriction policy computer exclusion group.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build

#>

Function Get-SoftwareRestrictionWhitelist {
    [CmdletBinding()]Param (
        
    )

    PROCESS {
        $SWExclusionName = "DoIT Software Restriction Policy Computer Exclusions"
        $SWExclusionGroup = Get-ADGroup -Filter "name -eq '$SWExclusionName'"

        if ($SWExclusionGroup -eq $null) {
             Write-Host "AD Group missing: $SWExclusionName" -ForegroundColor Red
             exit
        }

        (Get-ADGroupMember -Identity $SWExclusionName).name
    }
}
