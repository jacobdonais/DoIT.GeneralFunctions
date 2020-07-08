<#
.SYNOPSIS
    Adds a computer to the software exclusions list.

.DESCRIPTION
    The Add-SoftwareRestrictionWhitelist cmdlet adds a computer to the software exclusions security group in AD. 
    A gpupdate is needed followed by a restart before the exclusion list is successfully applied to the computer.

.NOTES

Author: Jacob Donais
Version: v1.4
Change Log:
    v1.0
        Initial build
    v1.1
        Added information to try/catch block for failed route. This is when the user does not have permission
        to either the AD computer object or the AD Security group for 'DoIT Software Restriction Policy Computer Exclusions'
    v1.2
        Added error checking in case the security group name changes
    v1.3
        Renamed cmdlet to Add-SoftwareRestrictionWhitelist
    v1.4
        Added array of computers
#>

Function Add-SoftwareRestrictionWhitelist {
    [CmdletBinding()]Param (
        [Parameter (
            Mandatory = $true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADComputer -Filter "name -eq '$_'") -ne $null})]
        [String[]]$ComputerName
    )

    PROCESS {
        $SWExclusionName = "DoIT Software Restriction Policy Computer Exclusions"
        $SWExclusionGroup = Get-ADGroup -Filter "name -eq '$SWExclusionName'"

        if ($SWExclusionGroup -eq $null) {
             Write-Host "0x00000001 Please contact script manager" -ForegroundColor Red
             break
        }

        foreach ($C in $ComputerName) {
            Write-Host "Adding $C to 'DoIT Software Restriction Policy Computer Exclusions' group... " -ForegroundColor Yellow -NoNewline
            try {
                $SWExclusionGroup | Add-ADGroupMember -Members (Get-ADComputer -Filter "name -eq '$C'") -ErrorAction Stop
                Write-Host "done"
            }
            catch {
                Write-Host "failed; check if you have permissions to edit $C or $SWExclusionName." -ForegroundColor Red
            }
        }
    }
}
