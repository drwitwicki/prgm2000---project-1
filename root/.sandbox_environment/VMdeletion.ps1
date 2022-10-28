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
Remove-VM -name $VMname
Remove-Item -r $VMPATH
