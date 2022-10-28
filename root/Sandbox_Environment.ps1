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

Function Setup-VM($VMname, $NumOfVMs) {
   $PresentVMs = Get-ChildItem $PATH\$USER
   $NumOfPresent = $PresentVMs.length
   if( [int]$numOfVMs+[int]$NumOfPresent -lt 10) {
      for ($i=1; $i -lt [int]$numOfVMs+1; $i++) {
         $IVMname = "$VMname$i"
         Invoke-Command -ComputerName $HVserver -FilePath ".\.sandbox_environment\VMcreation.ps1" -ArgumentList $USER,$IVMname
      }
   }
}

Function Destroy-VM()


$sandRunning = $TRUE
While ($sandRunning) {
   $VMs = Invoke-Command -ComputerName $HVserver -ScriptBlock { param ($USER); Get-VM  | Select -Property Name, Path, State} | Select -Property Name, Path, State

   $VMstring = $VMs | Out-String
   $VMlist = $VMs | Select -expandproperty Name

   $opt = @()
   $opt +=,@("Create VMs", 1)
   $opt +=,@("Destroy VM", 2)
   $opt +=,@("Destroy ALL", 3)
   $opt +=,@("Exit", 4)

   $sel = Build-Menu "Sandbox ENV" $VMstring $opt

   switch ($sel) {
      1 { $vmname = Read-Host " Name "; $numOfVMs = Read-Host " Amount "; Setup-VM $vmname $numOfVMs }
      4 { $sandRunning = $FALSE}
   }
}