$ConfirmPreference='Medium'
Function Copy-Script {
    [cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
    param(

        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = @('NEWCCI-HYPERV02',
                                    'NEWCCI-F1'),
                                            
        [ValidateNotNullOrEmpty()]
        [ValidateSet('UCS\MLEVAN')]
        [pscredential]$PSCreds= 'UCS\MLEVAN',

        [string]$ErrorLog = "C:\Users\$env:USERNAME\Desktop\CopyScriptLogError.txt",

        [switch]$LogError

    )

begin { $NewSession = New-PSSession -ComputerName $ComputerName -Credential $PSCreds }
        
process {
         
    TRY {
         $NoError = $true
         IF ($PSCmdlet.ShouldProcess($ComputerName)) {
                
             FOREACH ($Computer in $NewSession) {
                                
                Copy-item -Path 'C:\Test\mkdir.ps1' -Destination C:\CopiedScript -ToSession $Computer 

                }#FOREACH

            }#IF
        } #TRY
        
    CATCH{
            $NoError = False
            Write-Warning "An error has occured. Please review the error logs at the specified location"
            IF($LogError) {
            $Error[0] | Out-File $ErrorLog
            }

        }#CATCH

        }#Process
     
end{ Get-PSSession | Remove-PSSession }         
} #Function
