### VM Deletion
### Eric Caverly
### October 28th

param ($USER, $VMname)

$PATH = "E:"
$VMPATH = "$PATH\$USER\$VMname"

$VM = Get-VM $VMname
if($VM.state -eq "Running") {
    Stop-VM -name $VMname
}
Remove-VM -name $VMname -confirm:$FALSE -force
Remove-Item -r $VMPATH
