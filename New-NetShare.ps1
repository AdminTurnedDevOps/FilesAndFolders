Function New-NetShare {
    [cmdletbinding(SupportsShouldProcess,ConfirmImpact='medium')]

        param (
            [ValidateNotNullOrEmpty]
            [ValidateCount(1, 1)]
            [parameter(mandatory=$true)]
            [string]$UNCSHARE,

            [ValidateNotNullOrEmpty]
            [ValidateCount(1, 1)]
            [parameter(mandatory=$true)]
            [string]$DriveLetter,

            [string]$ErrorLog,

            [switch]$LogError

)
    
begin{Write-Verbose "Beginning the collection of the specific UNC path and mapping"}

process {
    Write-Verbose "Starting to find the UNC path"
    Write-Host -ForegroundColor Green "When typing in your UNC path, please do NOT put back spaces "//""

    TRY {
        Write-Verbose "Finding the UNC path. If the path is not found, prompt to retry"

            $NoErrors = $true
    do {

            $path = "filesystem::\\$UNCSHARE"
            $Testpath = Test-Path $path

    
                IF ($Testpath -match 'false') {

        Write-Host "The network drive does not exist. Please try again"
        continue
            
                                              }#IF Closing Bracket
    
                ELSEIF ($Testpath -match 'true') {
            
                    $PS_Drive_Params = @{
                            'Name'=$DriveLetter
                            'PSProvider'='FileSystem'
                            'Root'="\\$UNCSHARE"
                            'Persist'=$true
                                        }
            #cmdlet                        
            New-PSDrive @PS_Drive_Params
            break            

                                                  }#ELSEIF Closing Bracket
        }

    while('false')
                
                }#TRY Closing Bracket

    CATCH {
            $NoErrors = $false
            Write-Warning "Errors Occured. Please check the error log on your desktop"
            IF($LogError) {
            $Errors[0] | Out-File $ErrorLog
                          }

                }#CATCH Closing Bracket
            }#Process Closing Bracket
    end{}
}#Function Closing Bracket
