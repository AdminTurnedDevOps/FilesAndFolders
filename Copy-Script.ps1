$ConfirmPreference='Medium'
Function Push-Script {
    [cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
    param(

        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = @('PC1',
                                    'PC2
                                    'etc'),
                                            
        [ValidateNotNullOrEmpty()]
        [ValidateSet('DOMAINNAME\username')]
        [pscredential]$PSCreds= 'DOMAINNAME\USERNAME'

    )

begin { $NewSession = New-PSSession -ComputerName $ComputerName -Credential $PSCreds }
        
process {
            
         IF ($PSCmdlet.ShouldProcess($ComputerName)) {
                
             FOREACH ($Computer in $NewSession) {
                                
                Copy-item -Path 'C:\Test\yourscript.ps1' -Destination C:\CopiedScript -ToSession $Computer 

                }#FOREACH
                           
            }#IF

         }#Process
     
end{ Get-PSSession | Remove-PSSession }         
} #Function

Push-Script
