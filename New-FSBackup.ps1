                Function New-FSBackup {
                    [cmdletbinding(DefaultParameterSetName='CopyParam',SupportsShouldProcess=$true,ConfirmImpact = 'low')]

                    param(
                        [Parameter(ParameterSetName='CopyParam',HelpMessage='Please enter your errorlog folder if the default does not exist')]
                        [ValidateNotNullOrEmpty()]
                        [Alias('ErrorFolder','ErrorLogLocation')]
                        $ErrorLog = "C:\errorlogs\BackupError$(Get-date -Format MM.dd.yy).txt"
                    )

                    Begin {
                        #Test file paths and shares to confirm they are live and accessible.
                        $FileSharePath = '\\server\folder\foldername'
                        $TestFileShare = Test-Path $FileSharePath
                        $NAS1Path = '\\server\folder\foldername'
                        $NAS1Test = Test-Path $NAS1Path
                    }

                    Process {
                        TRY {
                            IF (-not ($TestFileShare -or $NAS1Test)) {
                                #If test-path fails for your specified locations, send an email.
                                $To = 'ToEmail'
                                $From = 'FromEmail'
                                $Creds = New-Object -TypeName System.Management.Automation.pscredential -ArgumentList $From, ('Password' | Convertto-securestring -AsPlainText -Force)
                                $SendMailPARAMS = @{
                                    'From'       = $From
                                    'To'         = $To
                                    'Subject'    = 'Backup did not start'
                                    'Body'       = "Copy of file share tried to start. Please check $FileSharePath and $NAS1Path. Paths do not exist or cannot be reached"
                                    'Credential' = $Creds
                                    'SmtpServer' = 'smtpserver'
                                    'Port'       = 'port'
                                    'Priority'   = 'high'                       
                                    'UseSSL'     = $true
                                }
                                Send-MailMessage @SendMailPARAMS
                            }#IF

                            ELSE {
                                #If test-path is true for all of your paths, do the copy/backup and push to a log
                                $CopyPARAMS = @{
                                    'Path'        = $FileSharePath
                                    'Destination' = '\\NAS\Folder'
                                    'Recurse'     = $true
                                    'Force'       = $true
                                    'Verbose'     = $true
                                }
                                Copy-Item @CopyPARAMS *> C:\backuplogs\logfile.txt
                            }#ELSE
                        }
                        CATCH {
                            Write-Warning 'An error has occured. Please review the error logs under C:\errorlogs\BackupError'
                            $_ | Out-File $ErrorLog
                            #Throw error to host
                            Throw
                        }
                    }#Process

                    End {
                        #Send an email once the script has completed.
                        $To = 'ToEmail'
                        $From = 'FromEmail'
                        $Creds = New-Object -TypeName System.Management.Automation.pscredential -ArgumentList $From, ('Password' | Convertto-securestring -AsPlainText -Force)
                        $SendMailPARAMS = @{
                            'From'       = $From
                            'To'         = $To
                            'Subject'    = 'File copy script has completed'
                            'Body'       = "Copy of file shares have finished. Please check the logs in C:\backuplogs. For any errors, please check C:\errorlogs\BackupError"
                            'Credential' = $Creds
                            'SmtpServer' = 'smtpserver'
                            'Port'       = 'port'
                            'Priority'   = 'high'                       
                            'UseSSL'     = $true
                        }
                        Send-MailMessage @SendMailPARAMS
                    }
                }#Function
