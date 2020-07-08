<#
.SYNOPSIS
    Adds a computer to the software exclusions list.

.DESCRIPTION
    The Add-SoftwareRestrictionExclusion cmdlet adds a computer to the exclusions list.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
    v1.1
        Added information to try/catch block for failed route. This is when the user does not have permission
        to either the AD computer object or the AD Security group for 'DoIT Software Restriction Policy Computer Exclusions'
    v1.2
        Added error checking in case the security group name changes
#>

Function Add-SoftwareRestrictionExclusion {
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

        Write-Host "Adding $ComputerName to 'DoIT Software Restriction Policy Computer Exclusions' group... " -ForegroundColor Yellow -NoNewline
        try {
            $SWExclusionGroup | Add-ADGroupMember -Members (Get-ADComputer -Filter "name -eq '$ComputerName'") -ErrorAction Stop
            Write-Host "done"
        }
        catch {
            Write-Host "failed; check if you have permissions to edit $ComputerName or $SWExclusionName." -ForegroundColor Red
        }
    }
}
