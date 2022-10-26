### Sandbox ENV
### Eric Caverly
### October 26th
. "..\.\functions.ps1"
$opt = @()
$opt +=,@("Create VMs", 1)
$opt +=,@("Select VM", 2)
$opt +=,@("Destroy Selected", 3)

$USER = whoami
$PATH = "\\D-SVR01\VMstorage\"

if ((Test-Path $PATH$USER) -eq $False) {
    New-Item -Path "$PATH" -Name "$USER" -ItemType "directory"
}


$VMs = Invoke-Command -ComputerName D-SVR01 -ScriptBlock { Get-VM | Where -filter {$_.path -eq "E:\VMFiles"} | Select -Property Name, Path, State} | Select -Property Name, Path, State

$VMstring = $VMs | Out-String

$sel = Build-Menu "Sandbox ENV" $VMstring $opt

#switch ($sel) {
   # 1 { Get-Current }
    #2 { Get-Custom }
#}
