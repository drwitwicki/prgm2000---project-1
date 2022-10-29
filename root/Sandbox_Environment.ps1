### Sandbox ENV
### Eric Caverly
### October 26th

. "..\.\functions.ps1"

$HVserver = "D-SVR01"
$VMPATH = "\\$HVserver\VMstorage"
$USER = whoami

if ((Test-Path $VMPATH\$USER) -eq $False) {
	New-Item -Path "$VMPATH" -Name "$USER" -ItemType "directory"
}

Function Setup-VM() {
	$VMname = Read-Host " Name "
	$numOfVMs = Read-Host " Amount (def:1) "
	if($numOfVMs -eq "") {
		$numOfVMs = 1
	}
	$VLAN = Read-Host " VLAN (leave empty for internet) "

	$PresentVMs = Get-ChildItem $VMPATH\$USER
	$NumOfPresent = $PresentVMs.length
	if( [int]$numOfVMs+[int]$NumOfPresent -lt 10) {
		for ($i=1; $i -lt [int]$numOfVMs+1; $i++) {
			$IVMname = "$VMname$i"
			if ((Test-Path $VMPATH\$USER\$IVMname) -eq $False) {
				Invoke-Command -ComputerName $HVserver -FilePath ".\.sandbox_environment\VMcreation.ps1" -ArgumentList $USER,$IVMname,$VLAN
			} else {
				Show-Message "VM with the name '$IVMname' already exists" yellow
			}
	  }
	} else {
		Show-Message "To many VMs, maximum of 10 VMs per user" red
	}
}

Function Destroy-VM($ALL, $VMlist) {
	if($ALL) {
		foreach ($VM in $VMlist) {
			Invoke-Command -ComputerName $HVserver -FilePath ".\.sandbox_environment\VMdeletion.ps1" -ArgumentList $USER,$VM
		}
	} else {
		$opt2 = @()
		foreach ($VM in $VMlist) {

			$opt2 +=,@($VM, $VM)
		}
		$VMname = Build-Menu "Sel VM" "Which VM should be deleted?" $opt2
		Invoke-Command -ComputerName $HVserver -FilePath ".\.sandbox_environment\VMdeletion.ps1" -ArgumentList $USER,$VMname
	}
}

$sandRunning = $TRUE
While ($sandRunning) {
	$modifiedUser = $USER.split("\")[1]
	$VMs = Invoke-Command -ComputerName $HVserver -ScriptBlock { param ($USER); Get-VM| Where-Object -filter {$_.path -match "$USER"} | Select -Property Name, State, CreationTime} -ArgumentList $modifiedUser | Select -Property Name, State, CreationTime
	
	$VMlist = $VMs | Select -expandproperty Name

	$opt = @()
	$opt +=,@("Create VMs", 1)
	if($VMlist.length -eq 0) {
			$VMstring = "No VMs"
		} else {
			$opt +=,@("Destroy VM", 2)
			$opt +=,@("Destroy ALL", 3)
			$VMstring = $VMs | Out-String
		}
	$opt +=,@("Refresh")
	$opt +=,@("Exit", 4)

	$sel = Build-Menu "Sandbox ENV" $VMstring $opt

	switch ($sel) {
		1 { Setup-VM }
		2 { Destroy-VM $FALSE $VMlist}
		3 { Destroy-VM $TRUE $VMlist}
		4 { $sandRunning = $FALSE}
	}
}