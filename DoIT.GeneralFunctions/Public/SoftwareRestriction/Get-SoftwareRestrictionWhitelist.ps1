<#
.SYNOPSIS
    Will return a list of devices in the software restriction exclusion group.

.DESCRIPTION
    The Get-SoftwareRestrictionWhitelist cmdlet will return a list of
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
        (Get-ADGroupMember -Identity $SWExclusionName).name
    }
}
