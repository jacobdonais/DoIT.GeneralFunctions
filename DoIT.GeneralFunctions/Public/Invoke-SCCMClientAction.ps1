<#
.SYNOPSIS
    Will run a client action on a remote computer

.DESCRIPTION
    The Run-SCCMClientAction cmdlet accepts a computer name and an array of 
    client actions to run.

.NOTES

Author: Jacob Donais
Version: v1.1
Change Log:
    v1.0
        Initial build
    v1.1
        Added pipeline feature by property name

#>

Function Invoke-SCCMClientAction {
    [CmdletBinding()]Param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter a computer name")]
        [Alias('ComputerName', 'CN')]
        [ValidateNotNullOrEmpty()]
        [String[]]$Name,

        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enter client action(s)")]
        [ValidateSet('FullHardwareInventory',
                     'DeltaHardwareInventory',
                     'GetIDMIF',
                     'FullSoftwareInventory',
                     'DeltaSoftwareInventory',
                     'CollectFiles',
                     'DiscoveryData',
                     'MachineAssignment',
                     'EvalulateMachinePolicies',
                     'MachinePolicyAgentCleanup',
                     'ValidateMachinePolicy',
                     'UserPolicyAgentCleanup',
                     'ValidateUserPolicy',
                     'ComplianceEvaluation',
                     'AppDeployment',
                     'UpdateEvaluation',
                     'UpdateScan')] 
        [string[]]$ClientAction
    )
    PROCESS {
        foreach ($C in $Name) {
            try {
                Invoke-Command -ComputerName $C -ScriptBlock {
                    param($ClientAction)
                    $Object = @()
                    foreach ($Action in $ClientAction) {

                        $ScheduleIDMappings = @{'FullHardwareInventory'     = '{00000000-0000-0000-0000-000000000001}'
                                                'DeltaHardwareInventory'    = '{00000000-0000-0000-0000-000000000001}'
                                                'GetIDMIF'                  = '{00000000-0000-0000-0000-000000000105}'
                                                'FullSoftwareInventory'     = '{00000000-0000-0000-0000-000000000002}'
                                                'DeltaSoftwareInventory'    = '{00000000-0000-0000-0000-000000000002}'
                                                'CollectFiles'              = '{00000000-0000-0000-0000-000000000104}'
                                                'DiscoveryData'             = '{00000000-0000-0000-0000-000000000003}'
                                                'MachineAssignment'         = '{00000000-0000-0000-0000-000000000021}'
                                                'EvalulateMachinePolicies'  = '{00000000-0000-0000-0000-000000000022}'
                                                'MachinePolicyAgentCleanup' = '{00000000-0000-0000-0000-000000000040}'
                                                'ValidateMachinePolicy'     = '{00000000-0000-0000-0000-000000000042}'
                                                'UserPolicyAgentCleanup'    = '{00000000-0000-0000-0000-000000000041}'
                                                'ValidateUserPolicy'        = '{00000000-0000-0000-0000-000000000041}'
                                                'ComplianceEvaluation'      = '{00000000-0000-0000-0000-000000000071}'
                                                'AppDeployment'             = '{00000000-0000-0000-0000-000000000121}'
                                                'UpdateEvaluation'          = '{00000000-0000-0000-0000-000000000108}'
                                                'UpdateScan'                = '{00000000-0000-0000-0000-000000000113}'}
                        $ScheduleID = $ScheduleIDMappings[$Action]
                        try {
                            [void]([wmiclass] "root\ccm:SMS_Client").TriggerSchedule($ScheduleID)
                            $Status = "Success"
                        }
                        catch {
                            $Status = "Failed"
                        }

                        $Object += New-Object psobject -Property ([ordered]@{
                            ActionName = $Action
                            Status = $Status
                        })
                    }

                    $Object
                } -ArgumentList (,$ClientAction) -ErrorAction Stop | Select-Object ActionName,Status,@{n='ComputerName';e={$_.pscomputername}}
            
            }
            catch {
                Write-Error $_.Exception.Message 
            }
        }
    }
}
