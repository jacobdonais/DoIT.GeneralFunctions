<#
.SYNOPSIS
    Removes a profile from a remote device then restarts it.

.DESCRIPTION
    The Remove-Profile function will remove the profile and restart the computer if and only if
    there is no user logged in.

.EXAMPLE
    *No user is logged in on doittech-227-6
    PS > Remove-WindowsProfile -UserName jacobd -ComputerName doittech-227-6

    Attempting to remove $UserName on doittech-227-6... done

.EXAMPLE
    *A user is logged in on doittech-227-6
    PS > Remove-WindowsProfile -UserName jacobd -ComputerName doittech-227-6

    A user is currently logged in on doittech-227-6.

.NOTES

Author: Jacob Donais
Version: v1.2
Change Log:
    v1.0
        Initial build
    v1.1 
        Changed the ordering of the restart to only restart when the profile has been removed.
        Changed the output text.
    v1.2
        Added examples
#>

Function Remove-WindowsProfile {
    [CmdletBinding()]Param (
        [Parameter (
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Enter a Username")]
        [ValidateNotNullOrEmpty()]
        [String]$UserName,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Enter an existing computer name")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { (Test-Connection $_ -Quiet -Count 1) -and
                ($env:COMPUTERNAME -ne $_) })]
        [String[]]$ComputerName
    )

    BEGIN {
        Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
    }

    PROCESS {
        foreach ($C in $ComputerName) {

            if ([string]::IsNullOrEmpty((Get-DSALoggedOnUser -ComputerName $C).USERNAME)) {
                Write-Host "Attempting to remove $UserName on $C... " -NoNewline

                try {
                    $RegexLocalPath = '\\' + $UserName + '[(\.)($)]'
                    $UserProfiles = Get-CimInstance -ClassName Win32_UserProfile -ComputerName $C | Where-Object { $_.LocalPath -match $RegexLocalPath }

                    if ($UserProfiles -eq $null) {
                        Write-Host "failed; profile does not exist" -ForegroundColor Red
                    }
                    else {
                        foreach ($UserProfile in $UserProfiles) {
                            try {
                                Remove-CimInstance -ComputerName $C -InputObject $UserProfile -ErrorAction SilentlyContinue -Confirm:$false
                                Invoke-Command -ComputerName $C -ScriptBlock { Restart-Computer -Force }
                                Write-Host "done"
                            }
                            catch {
                                Write-Host "failed; unable to Remove-CimInstance" -ForegroundColor Red
                            }
                        }
                    }
                }
                catch {
                    Write-Host "failed; unable to get Win32_UserProfile" -ForegroundColor Red
                }
            }
            else {
                Write-Host "A user is currently logged in on $C." -ForegroundColor Red
            }
        }
    }
}
