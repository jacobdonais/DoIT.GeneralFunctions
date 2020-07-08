<#
.SYNOPSIS
    Debugs a DSA profiles and points out obvious problems.

.DESCRIPTION
    The Debug-DSAUserAccount cmdlet output warnings if the account has been ADAutoCleanup, is an Elias account, is null or empty for 
    Name, UIN, NetID, Telephone Number, Department, Functional Group, Office, Descripition, Title, and eMail, account is locked and/or disabled,
    password is expired and/or over a year old, profile and home path missing and/or incorrect permissions.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
    v1.1
        Improved report output for readability
#>

Function Debug-DSAUserAccount {
    [CmdletBinding()]Param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            HelpMessage="Enter an AD username")]
        [ValidateNotNullOrEmpty()]
        [String]$UserName
    )

    Process {
        $ADAccount = Get-ADUser -Filter "SamAccountName -eq '$UserName'" -Properties *
        # Test if AD account exists
        if ($ADAccount -eq $null) {
            Write-Error "AD account does not exist" -ErrorAction Stop
        }

        Write-Host "Collecting account information for $($ADAccount.Name)..."

        # Check if account has been ADAutoCleanup
        if ($ADAccount.Description -match "ADAutoCleanup: Disabled \d+/\d+/\d\d\d\d") {
            Write-Host "$($matches[0])" -ForegroundColor Red
        }

    
        # Test if account is an Elias Account
        if ($ADAccount.ScriptPath -contains "login.exe") {
            Write-Host "Account is an Elias Account" -ForegroundColor Yellow
        }

        # Test Name
        if ([string]::IsNullOrEmpty($ADAccount.Name)) {
            Write-Host "Name is null or empty" -ForegroundColor Yellow
        
        }

        # Test UIN
        if ([string]::IsNullOrEmpty($ADAccount.EmployeeID)) {
            Write-Host "UIN is null or empty" -ForegroundColor Yellow
        }

        # Test NetID
        if ([string]::IsNullOrEmpty($ADAccount.EmployeeNumber)) {
            Write-Host "NetID is null or empty" -ForegroundColor Yellow
        
        }

        # Test Office Phone
        if ([string]::IsNullOrEmpty($ADAccount.telephoneNumber)) {
            Write-Host "Telephone number is null or empty" -ForegroundColor Yellow
        }

        # Test Department
        if ([string]::IsNullOrEmpty($ADAccount.Company)) {
            Write-Host "Department is null or empty" -ForegroundColor Yellow
        }

        # Test Functional Group
        if ([string]::IsNullOrEmpty($ADAccount.Department)) {
            Write-Host "Functional Group is null or empty" -ForegroundColor Yellow
        
        }

        # Test Location
        if ([string]::IsNullOrEmpty($ADAccount.Office)) {
            Write-Host "Office is null or empty" -ForegroundColor Yellow
        }

        # Test Description
        if ([string]::IsNullOrEmpty($ADAccount.Description)) {
            Write-Host "Description is null or empty" -ForegroundColor Yellow
        }

        # Test Title
        if ([string]::IsNullOrEmpty($ADAccount.Title)) {
            Write-Host "Title is null or empty" -ForegroundColor Yellow
        }

        # Test Email
        if ([string]::IsNullOrEmpty($ADAccount.Mail)) {
            Write-Host "eMail is null or empty" -ForegroundColor Yellow
        }

        # Troubleshoot account
        if ($ADAccount.lockedout -eq $true) {
            Write-Host "Account is locked out" -ForegroundColor Red
        }

        if ($ADAccount.enabled -eq $false) {
            Write-Host "Account is disabled" -ForegroundColor Red
        }

        if ($ADAccount.AccountExpirationDate -ne $NULL -and $ADAccount.AccountExpirationDate -lt (Get-Date)) {
            Write-Host "Account is expired" -ForegroundColor Red
        }

        if ($ADAccount.PasswordExpired -eq $true) {
            Write-Host "Account password is expired" -ForegroundColor Red
        }

        if ($ADAccount.pwdLastSet -eq 0) {
            Write-Host "Account is set to change password on next logon" -ForegroundColor Yellow
        }
        elseif ([datetime]::FromFileTime($ADAccount.pwdLastSet) -lt (Get-Date).AddYears(-1)) {
            Write-Host "Password is older than a year (Last set was $([datetime]::FromFileTime($ADAccount.pwdLastSet)))" -ForegroundColor Red
        }

        if ($ADAccount.CannotChangePassword -eq $true) {
            Write-Host "Account password cannot be changed by user" -ForegroundColor Red
        }

        # Test user path
        $ProfilePath = $ADAccount.ProfilePath
        $ValProfPerms = "Modify, Synchronize"
        # test if path exists
        try {
            Write-Verbose "Test if Profile path is null or empty..."
            if ([string]::IsNullOrEmpty($ProfilePath)) {
                Write-Host "Profile path is null or empty" -ForegroundColor Yellow
            }
            elseif ($ProfilePath -notmatch "%username%\\%username%") {
                Write-Host "Profile path may be incorrect. Reconfigure to %username%\%username%" -ForegroundColor Yellow
            }
            elseif (Test-Path -Path ($ProfilePath = Split-Path $ProfilePath.replace("%username%",$ADAccount.samaccountname))) {
                $ProfilePathPermissions = (Get-Acl $ProfilePath).Access | ?{$_.IdentityReference -match $ADAccount.SamAccountName} | Select IdentityReference,FileSystemRights
            
                if ($ProfilePathPermissions) {
                    if ($ProfilePathPermissions.FileSystemRights -eq $ValProfPerms) {
                        
                    }
                    else {
                        Write-Host "Incorrect permissions on profile path, has '$($ProfilePathPermissions.FileSystemRights)' rights (should be $ValProfPerms)" -ForegroundColor Red
                    }
                }
                else {
                    Write-Host "User does not have permissions to $ProfilePath" -ForegroundColor Red
                }

            }
            else {
                Write-Host "Profile path does not exist at $ProfilePath" -ForegroundColor Red
            }
        }
        catch [System.UnauthorizedAccessException] {
            Write-Warning "You don't have permissions to view that directory. Please contact your System Adminstrator for more information" -ErrorAction Continue
        }

        # Test home directory
        $HomeDirectory = $ADAccount.HomeDirectory
        $ValHomePerms = "Modify, Synchronize"
        # test if path exists
        try {
            if ([string]::IsNullOrEmpty($HomeDirectory)) {
                Write-Host "Home Directory is null or empty" -ForegroundColor Yellow
            }
            elseif (Test-Path -Path $HomeDirectory) {
                $HomeFolders = Get-ChildItem -Path $HomeDirectory -Directory
                foreach ($HomeFolder in $HomeFolders) {
                    $HomeDirectoryPermissions = (Get-Acl $HomeFolder.FullName).Access | ?{$_.IdentityReference -match $ADAccount.SamAccountName} | Select IdentityReference,FileSystemRights
                    if ($HomeDirectoryPermissions) {
                    
                        if ($HomeDirectoryPermissions.FileSystemRights -eq $ValHomePerms) {
                            
                        }
                        else {
                            Write-Host "Incorrect permissions on $HomeFolder, has '$($HomeDirectoryPermissions.FileSystemRights)' rights (should be $ValHomePerms)" -ForegroundColor Red
                        }
                    }
                    else {
                    
                        Write-Host "User does not have permissions to $HomeFolder" -ForegroundColor Red
                    }
                }
            }
            else {
                Write-Host "Home Directory does not exist at $HomeDirectory" -ForegroundColor Red
            }
        }
        catch [System.UnauthorizedAccessException] {
            Write-Warning "You don't have permissions to view that directory. Please contact your System Adminstrator for more information" -ErrorAction Continue
        }

        Write-Host "End of Report on $($ADAccount.Name)."
    }
}
