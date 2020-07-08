<#
.SYNOPSIS
    Will import the SCCM PS module

.DESCRIPTION
    The Enter-ConfigurationManager cmdlet will import the SCCM PS module pack.

.NOTES

Author: Jacob Donais
Version: v1.1
Change Log:
    v1.0
        Initial build
    v1.1
        Changed module path to "C:\Program Files (x86)\ConfigMgr Console"
        from "C:\Program Files (x86)\SCCM2012Console"

#>

Function Enter-ConfigurationManager {
    [CmdletBinding()]Param (
        
    )
    PROCESS {
        $ModuleName = "ConfigurationManager"

        # Load module if not already loaded
        if (-not(Get-Module -Name $ModuleName)) {
            $ModulePath = "C:\Program Files (x86)\ConfigMgr Console\bin"

            # Check if module exists
            if (-not(Test-Path -Path "$ModulePath\$($ModuleName).psd1")) {
                Write-Error "Unable to find $ModulePath\$ModuleName.psd1" -ErrorAction Stop
            }

            # Try to import it
            try {
                Import-Module "$ModulePath\$($ModuleName).psd1"
            }
            catch {
                Write-Error "Failed to Import Module" -ErrorAction Stop
            }
        }
    }
}
