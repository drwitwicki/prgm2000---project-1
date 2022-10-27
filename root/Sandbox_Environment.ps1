### Sandbox ENV
### Eric Caverly
### October 26th

. "..\.\functions.ps1"


$HVserver = "D-SVR01"
$GIpath = "\\$HVserver\VMstorage\GoldImages\GI\GoldImage\Virtual Machines\6761174C-C3AA-4335-8BFC-1354FAFCC043.vmcx"
$PATH = "\\$HVserver\VMstorage\"

Function Setup-VM($VMname) {
   Invoke-Command -ComputerName $HVserver -ScriptBlock {
      param ($GIpath, $PATH, $USER, $VMname)
      
      New-Item -Path "$PATH\$USER" -Name "$VMname" -ItemType "directory"
      Copy-Item $GIpath "$PATH\$USER\$VMname\$VMname.vmcx"

      #Import-VM
   } -ArgumentList $GIpath,$PATH,$USER,$VMname
}


$opt = @()
$opt +=,@("Create VMs", 1)
$opt +=,@("Destroy Selected", 2)
$opt +=,@("Exit", 3)

$USER = whoami


if ((Test-Path $PATH$USER) -eq $False) {
    New-Item -Path "$PATH" -Name "$USER" -ItemType "directory"
}

$VMs = Invoke-Command -ComputerName D-SVR01 -ScriptBlock { Get-VM | Where -filter {$_.path -eq "E:\VMFiles"} | Select -Property Name, Path, State} | Select -Property Name, Path, State

$VMstring = $VMs | Out-String

$sel = Build-Menu "Sandbox ENV" $VMstring $opt

switch ($sel) {
   1 { $vmname = Read-Host " Name "; Setup-VM $vmname }

}
