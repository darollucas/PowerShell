# As a prerequisite to start converting VMware VMs to Hyper-V four times faster, upgrade to SCVMM 2022 UR2 or later.
# As part of SCVMM 2022 UR2, a new registry named V2VTransferChunkSizeBytes is introduced at HKLM:\SOFTWARE\Microsoft\Microsoft System Center Virtual Machine Manager Agent in the Hyper-V hosts managed by SCVMM.
# This registry of type REG_DWORD, with a value of 2147483648, which is 2 GB in bytes has to be set on every Hyper-V host managed by VMM by running this script from the VMM Console.
# After setting this registry value, if you remove any Hyper-V host(s) from SCVMM, stale entries for this registry might remain. If the same host(s) is re-added to SCVMM, the previous value of registry V2VTransferChunkSizeBytes will be honored.
# https://learn.microsoft.com/en-us/system-center/vmm/vm-convert-vmware?view=sc-vmm-2022
	$hosts = Get-SCVMHost -VMMServer <VMMServer>
	foreach($VMHost in $hosts)
	{
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
	}
