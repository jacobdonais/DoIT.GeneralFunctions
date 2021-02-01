<#
.SYNOPSIS
    Test if a given username is part of a group.

.DESCRIPTION
    The Test-MemberOf function determines if a member if a part of an AD group.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
#>

Function Test-DSAUserMemberOf {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter an AD username")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADUser -Filter "samaccountname -eq '$_'") -ne $null})]
        [String]$UserName,
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter an AD Group")]
        [ValidateScript({(Get-ADGroup -Filter "SAMAccountName -eq '$_'") -ne $null})]
        [String]$ADGroup
    )

    PROCESS {
        $members = Get-ADGroupMember -Identity $ADGroup -Recursive | Select -ExpandProperty SamAccountName

        if ($members -contains $username) {
            return $true
        } else {
            return $false
        }
    }
}
