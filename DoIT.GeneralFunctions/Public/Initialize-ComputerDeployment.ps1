<#
.SYNOPSIS
    The Initialize-ComputerDeployment function will move the new computer to the
    OU of the old device and will apply a description to the new object.

.DESCRIPTION
    The Initialize-ComputerDeployment cmdlet will perform the following:
    1. Apply AD description to new computer
        case i: AD description supplied in parameters.
        case ii: AD description is supplied from the old computer.
        case iii. No AD description on old computer, prompt user for description
    2. Move new computer to the OU of the old computer
    3. (optional) Disable the old computer object.
    4. (optional) Delete the old computer object
    5. Check DNS records

.INPUTS
    String

.OUTPUTS
    None

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build

#>

Function Initialize-ComputerDeployment {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Enter the old computer name")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $null -ne (Get-ADComputer -Filter "name -eq '$_'") })]
        [String]$OldComputerName,
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Enter the new computer name")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $null -ne (Get-ADComputer -Filter "name -eq '$_'") })]
        [String]$NewComputerName,
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Enter a description")]
        [ValidateNotNullOrEmpty()]
        [String]$Description,
        [Parameter(Mandatory = $false)]
        [Switch]$Disable,
        [Parameter(Mandatory = $false)]
        [Switch]$Delete
    )

    BEGIN {
        Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
    }

    PROCESS {
        ### Apply an AD description
        if ([string]::IsNullOrEmpty($Description)) {
            Write-Host "Getting AD Description from original device..." -NoNewline
            try {
                $Description = (Get-ADComputer -Filter "name -eq '$OldComputerName'" -Properties description -ErrorAction Stop).description
                Write-Host "done; $Description" -ForegroundColor Yellow
            }
            catch {
                Write-Host "failed" -ForegroundColor Red
            }
        }
        if ([string]::IsNullOrEmpty($Description)) {
            $Description = Read-Host -Prompt "Description is null or empty. Enter a new description or leave blank" -ErrorAction SilentlyContinue
        }
        if ([string]::IsNullOrEmpty($Description)) {
            Write-Host "Description is null or empty. No change made."
        }
        else {
            Write-Host "Applying description to new computer... " -NoNewline
            try {
                Get-ADComputer -Filter "name -eq '$NewComputerName'" | Set-ADComputer -Description $Description -ErrorAction Stop
                Write-Host "done; $Description" -ForegroundColor Yellow
            }
            catch {
                Write-Host "faled" -ForegroundColor Red
                exit
            }
        }

        ### Move Computer to Correct OU
        Write-Host "Getting the desired OU... " -NoNewline
        try {
            $DesiredOU = ((Get-ADComputer -Filter "name -eq '$OldComputerName'" -ErrorAction Stop).distinguishedname -split ",", 2)[1]
            Write-Verbose "Desired OU : $DesiredOU"
            $DesiredPath = (Get-ADComputer -Filter "name -eq '$OldComputerName'" -Properties * -ErrorAction Stop).canonicalName -replace $OldComputerName, ""
            Write-Host "done; $DesiredPath" -ForegroundColor Yellow
        }
        catch {
            Write-Host "failed" -ForegroundColor Red
            exit
        }

        Write-Host "Moving new computer to the desired OU... " -NoNewline
        try {
            Get-ADComputer -Filter "name -eq '$NewComputerName'" -ErrorAction Stop | Move-ADObject -TargetPath $DesiredOU -Confirm:$false -ErrorAction Stop
            Write-Host "done" -ForegroundColor Yellow
        }
        catch {
            Write-Host "faled" -ForegroundColor Red
            exit
        }

        ### Disable old object
        if ($Disable) {
            Write-Host "Disabling old computer... " -NoNewline
            try {
                Get-ADComputer -Filter "name -eq '$OldComputerName'" | Disable-ADAccount -Confirm:$false -ErrorAction Stop
                Write-Host "done" -ForegroundColor Yellow
            }
            catch {
                Write-Host "faled" -ForegroundColor Red
                exit
            }
        
        }

        ### Delete old object
        if ($Delete) {
            Write-Host "Deleting old computer... " -NoNewline
            try {
                Get-ADComputer -Filter "name -eq '$OldComputerName'" | Remove-ADComputer -Confirm:$false -ErrorAction Stop
                Write-Host "done" -ForegroundColor Yellow
            }
            catch {
                Write-Host "faled" -ForegroundColor Red
                exit
            }
        
        }

        ### Provide a pretty message to apply AD changes
        Write-Host "Please restart the new workstation for the AD changes!" -ForegroundColor Green

        ### Check for DNS record
        Write-Host "Checking for DNS record... " -NoNewline
        try {
            $DNSRecord = Resolve-DnsName $NewComputerName -Server "dsa.reldom.tamu.edu" -ErrorAction Stop
            if ($DNSRecord.count -gt 1) {
                Write-Host "failed; more than one DNS record was returned" -ForegroundColor Red
            }
            else {
                Write-Host "done; $($DNSRecord.IPAddress)" -ForegroundColor Yellow
                Write-Host "Testing if DNS record matches new computer record..." -NoNewline
                if (Test-Connection -ComputerName $NewComputerName -Count 1 -Quiet) {
                    try {
                        $Hostname = Invoke-Command -ComputerName $NewComputerName -ScriptBlock { hostname } -ErrorAction Stop
                        if ($Hostname -eq $NewComputerName) {
                            Write-Host "passed" -ForegroundColor Yellow
                        }
                        else {
                            Write-Host "failed; resolved to $Hostname" -ForegroundColor Red
                        }
                    }
                    catch {
                        Write-Host "failed; unable to query the computer. This could mean that the DNS record is incorrect" -ForegroundColor Red
                    }
                }
                else {
                    Write-Host "Computer is offline. Please ensure the device is connected to the network and the DNS record has updated." -ForegroundColor Red
                }
            }
        }
        catch {
            Write-Host "failed; No DNS Record exists for $NewComputerName. Please confirm the new computer is on the correct DNS servers." -ForegroundColor Red
        }
    }
}
