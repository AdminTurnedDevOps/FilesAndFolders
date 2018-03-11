Function Remove-SMB1 {
    [cmdletbinding(DefaultParameterSetName = 'SMB1.0', SupportsShouldProcess = $true, ConfirmImpact = 'high')]
    param (
        [Parameter(ParameterSetName = 'SMB1.0',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Please type in computer names')]
        [ValidateNotNullOrEmpty()]
        [Alias('PCName', 'Hostname')]
        [string[]]$ComputerName,

        [string]$ErrorLog = (Read-Host 'Please put in a location for the error log to be placed')
    )

    Begin {
        Write-Verbose 'Collecting information for SMB query and V1'
        $NewSession = New-PSSession -ComputerName $ComputerName -Credential (Get-Credential)
        $SMBV1 = Get-smb -Version 1
        $SMB = Get-InstalledModule | Where-Object {$_.Name -like 'PSSmb'}   
    }

    Process {
        TRY {
        Write-Verbose 'Processing PSCmdlet to propt for $NewSession'
        if ($PSCmdlet.ShouldProcess($NewSession)) {
            Invoke-Command -Session $NewSession -ScriptBlock {

                Write-Verbose 'Installing PSSmb if not already installed'
                Write-Verbose 'Disabling SMBv1'
                IF ($SMB -notcontains 'PSSmb') {
                    Install-Module PSSmb -Force
                    Import-Module PSSmb
                    Disable-Smb -Version 1 
                }#IF2
                
                ELSEIF ($SMBV1.SmbClientV1 -like 'True') {
                    Write-Verbose 'Removing SMBv1 if PSSmb was already installed'               
                    Disable-Smb -Version 1
                }#ELSEIF
               
            }#ScriptBlock
            Write-Verbose 'Script block closed'  
        }#IF1_PSCmdlet
        Write-Verbose 'Collecting SMBv1 info on PSSession machines'
        $SMBv1STATUS = Get-SMB -version 1 -ComputerName $ComputerName
        FOREACH ($Computer in $ComputerName) {
            $SMBv1_Objects = [pscustomobject] @{
                'HostName'   = $Computer
                'SMBClient1' = $SMBv1STATUS.SmbClientV1
                'SMBServer1' = $SMBv1STATUS.SmbServerV1
            }
            Write-Verbose 'Writing output to host'
            #Adding some members for pushing out a success log and pinging the computers
            $SMBv1_Objects | Add-Member -MemberType ScriptMethod -Name pingComputers -Value {Test-Connection $Computer}
            $SMBv1_Objects | Add-member -MemberType ScriptMethod -Name ToLog -Value {Out-File}

            #Write-Output to the screen and to a log if needed
            Write-Output $SMBv1_Objects 
        }

    }
    CATCH {
            Write-Warning 'An error has occured. Please review the full error log for more details'
            $_ | Out-File $ErrorLog
            #Throw error to screen
            Throw
    }
    }#PROCESS
    End {
        Write-Verbose 'Ending all PSSessions'
        Get-PSSession | Remove-PSSession
    }
}#Function
