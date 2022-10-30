### Sandbox ENV
### Eric Caverly
### October 26th

. "..\.\functions.ps1"

$HVserver = "D-SVR01"                   # Customizable Variables, change based on environment
$VMPATH = "\\$HVserver\VMstorage"
$USER = whoami

if ((Test-Path $VMPATH\$USER) -eq $False) {     # Check if the user running the script has their own folder
	New-Item -Path "$VMPATH" -Name "$USER" -ItemType "directory"
}

Function Setup-VM() {                           # Setup VM(s), this function calls the external script to build VM(s)
	$VMname = Read-Host " Name "                # Get data from user
	$numOfVMs = Read-Host " Amount (def:1) "    
	if($numOfVMs -eq "") {                      # If no amount is specficed assume 1
		$numOfVMs = 1
	}
	$VLAN = Read-Host " VLAN (leave empty for internet) "  # VLANs are used to segregate VMs. This approach was selected to allow different users to make VMs that can communicate, or allow users to make completely segregated VMs

	$PresentVMs = Get-ChildItem $VMPATH\$USER          # Get all current VM folders
	$NumOfPresent = $PresentVMs.length
	if( [int]$numOfVMs+[int]$NumOfPresent -lt 10) {    # Make sure the user is not exceeding their limit (10/user)
		for ($i=1; $i -lt [int]$numOfVMs+1; $i++) {    # For each VM to be created, make a name and run the script with required arguments
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

Function Destroy-VM($ALL, $VMlist) {        # Wipe away specfic or all VMs
	if($ALL) {
		foreach ($VM in $VMlist) {
			Invoke-Command -ComputerName $HVserver -FilePath ".\.sandbox_environment\VMdeletion.ps1" -ArgumentList $USER,$VM
		}
	} else {
		$opt2 = @()
		foreach ($VM in $VMlist) {        # Build a new menu asking which VM should be deleted

			$opt2 +=,@($VM, $VM)
		}
		$VMname = Build-Menu "Sel VM" "Which VM should be deleted?" $opt2
		Invoke-Command -ComputerName $HVserver -FilePath ".\.sandbox_environment\VMdeletion.ps1" -ArgumentList $USER,$VMname
	}
}

$sandRunning = $TRUE            # While loop is used to make program interactive
While ($sandRunning) {
	$modifiedUser = $USER.split("\")[1]    # Get just the username ignoring domain, required for getting current VMs

    # Get a table of current VMs and some properties:
	$VMs = Invoke-Command -ComputerName $HVserver -ScriptBlock { param ($USER); Get-VM| Where-Object -filter {$_.path -match "$USER"} | Select -Property Name, State, CreationTime} -ArgumentList $modifiedUser | Select -Property Name, State, CreationTime
	
	$VMlist = $VMs | Select -expandproperty Name

	$opt = @()                         # Build a menu for VM manipulation
	$opt +=,@("Create VMs", 1)
	if($VMlist.length -eq 0) {         # Change options available based on whether VMs are present or not
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