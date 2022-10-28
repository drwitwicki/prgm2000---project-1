### VM Deletion
### Eric Caverly
### October 28th

param ($USER, $VMname)

$PATH = "E:"
$VMPATH = "$PATH\$USER\$VMname"

Remove-VM -name $VMname
Remove-Item -r $VMPATH