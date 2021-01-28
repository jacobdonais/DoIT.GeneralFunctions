<#
.SYNOPSIS
    Checks if a user is in the remoteapps groups and if they're a local remote desktop user.

.DESCRIPTION
    The Test-RemoteDesktopUser cmdlet checks if the user is a member of the REMOTEAPPS - User group
    and checks if they're a member of the local remote desktop user group on the computer.

.INPUTS
    String

.OUTPUTS
    PSCustomObject

.NOTES

Author: Jacob Donais
Version: v1.2
Change Log:
    v1.0
        Initial build
    v1.1
        Expanded test-remotedesktop user to accept array of computers.
    v1.2
        Added the ability to test local computer

#>

Function Test-RemoteDesktopUser {
    [CmdletBinding()]Param (
        [Parameter (
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Get-ADUser -Filter "samaccountname -eq '$_'") -ne $null})]
        [String]$UserName,

        [Parameter (
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({((Get-ADComputer -Filter "name -eq '$_'") -ne $null)})]
        [String[]]$ComputerName
    )


    PROCESS {
        Write-Verbose "Testing if user is a member of RemoteApps..."
        $ADRemoteApps = "REMOTEAPPS - Users"
        try {
            if (Test-DSAUserMemberOf -UserName $UserName -ADGroup $ADRemoteApps) {
                Write-Verbose " $UserName is a member of $ADRemoteApps"
                $isRDPUser = $true
            }
            else {
                Write-Verbose " $UserName is not a member of $ADRemoteApps"
                $isRDPUser = $false
            }
        }
        catch {
            Write-Error "Please contact script manager" -ErrorAction Stop -ErrorId "ADGroup.RemoteApps.InvalidName"
            break
        }
        
        if ($ComputerName) {
            foreach ($C in $ComputerName) {
                
                if (Test-Connection -ComputerName $C -Count 1 -Quiet) {
                    Write-Verbose "Testing if user is in the Remote Desktop User Group on $ComputerName..."
                    $isLocalRDPUser = $false
                    try {
                        if ($env:COMPUTERNAME -eq $C) {
                            $LocalRDPmembers = Get-LocalGroupMember -Name "Remote Desktop Users"
                        }
                        else {
                            $LocalRDPmembers = Invoke-Command -ComputerName $C -ScriptBlock {(Get-LocalGroupMember -Name "Remote Desktop Users")}
                        }
                    }
                    catch {
                        Write-Error "Please contact script manager" -ErrorAction Stop -ErrorId "ADGroup.RemoteApps.InvalidGrab"
                        break
                    }
                    $LocalRDPmembers | ForEach-Object {
                        $GroupName = $_.name -replace "DSA\\",""
                        if ($_.ObjectClass -eq "Group") {
                            if (Test-DSAUserMemberOf -UserName $UserName -ADGroup $GroupName) {
                                $isLocalRDPUser = $true
                            }
                        }
                        elseif ($_.ObjectClass -eq "User") {
                            if ($GroupName -eq $UserName) {
                                $isLocalRDPUser = $true
                            }
                        }
                    }
                    if ($isLocalRDPUser) {
                        Write-Verbose " $UserName is a local remote desktop user for $C"
                    }
                    else {
                        Write-Verbose " $UserName is not a local remote desktop user for $C"
                    }

                    New-Object psobject -Property ([ordered]@{
                            UserName = $UserName
                            ComputerName = $C
                            RemoteAppsUser = $isRDPUser
                            LocalRemoteDesktopUser = $isLocalRDPUser
                        })
                }
                else {
                    New-Object psobject -Property ([ordered]@{
                            UserName = $UserName
                            ComputerName = $C
                            RemoteAppsUser = $isRDPUser
                            LocalRemoteDesktopUser = "Computer offline"
                        })
                }
            }
        }
        else {
            New-Object psobject -Property ([ordered]@{
                    UserName = $UserName
                    RemoteAppsUser = $isRDPUser
                })
        }
    }
}

