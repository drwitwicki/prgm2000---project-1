### VM Creation
### Eric Caverly
### October 26th

### Inpsired by https://www.youtube.com/watch?v=v45SQwvho94

param ($USER, $VMname)

$PATH = "E:"
$VMPATH = "$PATH\$USER\$VMname"
$VHDXPATH = "$VMPATH\$VMname.vhdx"
$GIpath = "$PATH\GoldImages\GoldImage\GoldImage.vhdx"

$vmswitch = "vswitch1"
$port = "port1"
$cpu = 2
$ram = 2GB
$disksize = 20GB

New-VM $VMname -Path "$PATH\$USER"
Set-VM $VMname -ProcessorCount $cpu -MemoryStartupBytes $ram
New-VHD -Path $VHDXPATH -ParentPath $GIpath
Add-VMHardDiskDrive -VMname $VMname -Path $VHDXPATH

