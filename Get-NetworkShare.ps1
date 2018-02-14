Function Get-NetworkShare {

<#
.SYNOPSIS
Get folders/network drives from remote network shares on a specific machine.
.DESCRIPTION
This script is for getting remote network mapped to a specified machine. You will be able to see the full path of the network share.
.PARAMETER
The ComputerName parameter is to specify a computer name.
.EXAMPLE
'localhost' | Get-RemoteSMBShare
#>

    [cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='low')]
    param (

        [parameter(mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [alias('hostname')]
        [ValidateCount(1, 5)]
        [string[]]$ComputerName,

        [string]$ErrorLog = "C:\Users\$env:USERNAME\Desktop\NetShareErrorLog$(Get-date -Format MM.dd.yy).txt"
)

BEGIN{ Write-Verbose "Attemtping to pull network share info" }

PROCESS{

    TRY {
                $NoErrors = $true
                $Params = @{
                            'Class'='Win32_MappedLogicalDisk'
                            'ComputerName'=$ComputerName
                           }
                $WMI = Get-wmiobject @Params

                    $Obj = [PSCustomObject] @{
                        'NetShare'=$WMI.ProviderName
                                             }
                                
                            Write-output $Obj
       }#TRY 
    
    CATCH {
        $NoErrors = $false
        Write-Warning "Sorry, but there was an error. Please check your desktop for the NetShareErrorLog"
        IF ($LogErrors) {
        $Error | Out-File $ErrorLog -Append }
            
          }#CATCH        

        }#PROCESS
END{}
}#FUNCTION
