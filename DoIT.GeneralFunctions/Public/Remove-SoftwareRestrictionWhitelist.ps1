<#
.SYNOPSIS
    Removes a computer from the software exclusions list.

.DESCRIPTION
    The Remove-SoftwareRestrictionWhitelist function removes a computer from the exclusions list.

.NOTES

Author: Jacob Donais
Version: v1.4
Change Log:
    v1.0
        Initial build
    v1.1
        Added error checking in case the security group name changes
    v1.3
        Renamed cmdlet to Remove-SoftwareRestrictionWhitelist
    v1.4
        Added array of computers
#>

Function Remove-SoftwareRestrictionWhitelist {
    [CmdletBinding()]Param (
        [Parameter (
            Mandatory = $true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADComputer -Filter "name -eq '$_'") -ne $null})]
        [String[]]$ComputerName
    )

    BEGIN {
        $SWExclusionName = "DoIT Software Restriction Policy Computer Exclusions"
        $SWExclusionGroup = Get-ADGroup -Filter "name -eq '$SWExclusionName'"

        if ($SWExclusionGroup -eq $null) {
             Write-Host "AD Group missing: $SWExclusionName" -ForegroundColor Red
             exit
        }
    }

    PROCESS {
        foreach ($C in $ComputerName) {
            Write-Host "Removing $C from 'DoIT Software Restriction Policy Computer Exclusions' group... " -ForegroundColor Yellow -NoNewline
            try {
                $SWExclusionGroup | Remove-ADGroupMember -Members (Get-ADComputer -Filter "name -eq '$C'") -ErrorAction Stop -Confirm:$false
                Write-Host "done"
            }
            catch {
                Write-Host "failed; check if you have permissions to edit $C or $SWExclusionName." -ForegroundColor Red
            }
        }
    }
}
