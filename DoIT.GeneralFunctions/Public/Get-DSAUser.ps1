<#
.SYNOPSIS
    Gets a DSA user account and displays relevent information.

.DESCRIPTION
    The Get-DSAUser function searches for an AD account based on either UIN, UserName,
    NetID, or Name, and displays relevent information back.

.NOTES

Author: Jacob Donais
Version: v1.0
Change Log:
    v1.0
        Initial build
#>

Function Get-DSAUser {
    [CmdletBinding()]Param(
        [Parameter(
            Mandatory = $true, 
            ValueFromPipeline = $true,
            HelpMessage = "Enter a value")]
        [ValidateNotNullOrEmpty()]
        [String[]]$Value
    )

    PROCESS {
        foreach ($V in $Value) {
            $ADAccounts = @()

            $ADAccounts += Get-ADUser -Filter "EmployeeID -eq '$V'" -Properties *
            $ADAccounts += Get-ADUser -Filter "SamAccountName -eq '$V'" -Properties *
            $ADAccounts += Get-ADUser -Filter "EmployeeNumber -eq '$V'" -Properties *
            $ADAccounts += Get-ADUser -Filter "Name -like '*$V*'" -Properties *

            $ADAccounts = $ADAccounts | Select-Object -Unique
    
            foreach ($ADAccount in $ADAccounts) {
                $accountReturn = [ordered]@{
                    Name                   = $ADAccount.name
                    UIN                    = $ADAccount.EmployeeID
                    NetID                  = $ADAccount.EmployeeNumber
                    UserName               = $ADAccount.SamAccountName
                    Email                  = $ADAccount.EmailAddress
                    Department             = $ADAccount.Company
                    Functional             = $ADAccount.Department
                    Office                 = $ADAccount.Office
                    Phone                  = $ADAccount.OfficePhone
                    Other                  = $ADAccount.otherTelephone
                    Description            = $ADAccount.Description
                    Title                  = $ADAccount.Title
                    Enabled                = $ADAccount.Enabled
                    LockedOut              = $ADAccount.LockedOut
                    LastBadPasswordAttempt = $ADAccount.LastBadPasswordAttempt
                    HomeDirectory          = $ADAccount.HomeDirectory
                    ProfilePath            = $ADAccount.ProfilePath
                    OU                     = $ADAccount.DistinguishedName
                    Expires                = $ADAccount.AccountExpirationDate
                    PasswordLastSet        = $([datetime]::FromFileTime($ADAccount.pwdLastSet))
                    UserGroups             = (Get-ADPrincipalGroupMembership -Identity $ADAccount).name
                }
                [PSCustomObject]$accountReturn
            }
        }
    }
}
