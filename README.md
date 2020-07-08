# DoIT.GeneralFunctions
The DoIT.GeneralFunctions module pack aims to reduce the workload for DoIT Service Desk. 

## Installing
### Install traditionally
1. Download the module pack and place it in the Module folder. You can list/edit your modules path with `$env:PSModulePath`. Preferred path to place this module pack is `C:\Program Files\WindowsPowerShell\Modules`
2. Run Powershell as an admin and enter this command
```
Import-Module -Name DoIT.GeneralFunctions
```
3. Restart Powershell

### Install with script
1. Download the script file `InstallDoITGeneralFunctions.ps1`.
2. Open Powershell as an admin and run the script file.
3. Enter computer names that you would like to install the module on.

*Use `-verbose` to get more information while the script is running.*

## Examples
**Example 1: List available cmdlets in module pack**
```
Get-Command -Module DoIT.GeneralFunctions
```
Copyright (C) 2020 Jacob Donais
