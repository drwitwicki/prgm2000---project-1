### Sandbox ENV
### Eric Caverly
### October 26th

. "..\.\functions.ps1"

$HVserver = "D-SVR01"
$PATH = "\\$HVserver\VMstorage"
$USER = whoami


if ((Test-Path $PATH\$USER) -eq $False) {
    New-Item -Path "$PATH" -Name "$USER" -ItemType "directory"
}

Function Setup-VM() {
   $VMname = Read-Host " Name "
   $numOfVMs = Read-Host " Amount ";

   $PresentVMs = Get-ChildItem $PATH\$USER
   $NumOfPresent = $PresentVMs.length
   if( [int]$numOfVMs+[int]$NumOfPresent -lt 10) {
      for ($i=1; $i -lt [int]$numOfVMs+1; $i++) {
         $IVMname = "$VMname$i"
         Invoke-Command -ComputerName $HVserver -FilePath ".\.sandbox_environment\VMcreation.ps1" -ArgumentList $USER,$IVMname
      }
   }
}

Function Destroy-VM($All) {
	if($ALL) {
		
	} else {

	}
}


$sandRunning = $TRUE
While ($sandRunning) {
	$modifiedUser = $USER.split("\")[1]
	$VMs = Invoke-Command -ComputerName $HVserver -ScriptBlock { param ($USER); Get-VM| Where-Object -filter {$_.path -match "$USER"} | Select -Property Name, State, CreationTime} -ArgumentList $modifiedUser | Select -Property Name, State, CreationTime

	$VMstring = $VMs | Out-String
	$VMlist = $VMs | Select -expandproperty Name

	$opt = @()
	$opt +=,@("Create VMs", 1)
	$opt +=,@("Destroy VM", 2)
	$opt +=,@("Destroy ALL", 3)
	$opt +=,@("Exit", 4)

	$sel = Build-Menu "Sandbox ENV" $VMstring $opt

	switch ($sel) {
		1 { Setup-VM }
		2 { Destroy-VM $FALSE}
		3 { Destroy-VM $TRUE }
		4 { $sandRunning = $FALSE}
	}
}