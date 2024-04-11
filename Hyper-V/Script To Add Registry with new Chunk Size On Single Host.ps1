	$VMHost = Get-SCVMHost -ComputerName "<hostname>" -VMMServer "<VMMServer>"
	If($VMHost.VirtualizationPlatform -eq "HyperV")
	{
		$scriptSetting = New-SCScriptCommandSetting
		Set-SCScriptCommandSetting -ScriptCommandSetting $scriptSetting -WorkingDirectory "" -PersistStandardOutputPath "" -PersistStandardErrorPath "" -MatchStandardOutput "" -MatchStandardError ".+" -MatchExitCode "[1-9][0-9]*" -FailOnMatch -RestartOnRetry $false -MatchRebootExitCode "{1641}|{3010}|{3011}" -RestartScriptOnExitCodeReboot $false -AlwaysReboot $false
		Invoke-SCScriptCommand -Executable "%WinDir%\System32\WindowsPowershell\v1.0\powershell.exe" -TimeoutSeconds 120 -CommandParameters 	{
		              $registryPath = 'HKLM:\SOFTWARE\Microsoft\Microsoft System Center Virtual Machine Manager Agent'
		 	$Name = 'V2VTransferChunkSizeBytes'
		 	$value = '2147483648'
		 	if(Test-Path -Path $registryPath)
		 	{
		 		New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force
		 	}
		} -VMHost $VMHost -ScriptCommandSetting $scriptSetting
	}
