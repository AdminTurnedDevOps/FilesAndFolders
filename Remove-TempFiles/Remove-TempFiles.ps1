Function Remove-TempFiles {

	param(
		[string]$Temp = "C:\temp",

		[string]$VariableTempDirectory = $env:TEMP,

		[string]$ErrorLog = "$env:USERPROFILE\Desktop\ErrorLog.txt",

		[switch]$LogError
)


Write-Output "Removing temp files will now begin"
Write-Verbose "Removing temp files in the TEMP environment variable"

BEGIN{}

PROCESS {

	TRY {
			$ScriptWorked = $true
			FOREACH ($Directory in $VariableTempDirectory) {

				Remove-Item -Path $env:TEMP -ErrorAction SilentlyContinue
			}

Write-Verbose "Removing temo files in C:\Temp"

			$MainDirectory = $Temp

			FOREACH ($Directory in $MainDirectory) {

				Get-childitem $Temp | Remove-Item
			}
   } CATCH {
			$ScriptWorked = $false
			Write-Output "Sorry, your script has failed. Please review the ErrorLog.txt file on your desktop"
			IF ($LogError) {
			$Error | Out-File $ErrorLog
			
		}
	}
}
	
Write-Output "Removal of temp files is now complete"
Write-Verbose "Removed files in the TEMP environment variable and under C:\Temp"
Write-Verbose "The C:\Temp directory still exists. All child items are removed"

END{}

}#FunctionClosingBracket

Remove-TempFiles
