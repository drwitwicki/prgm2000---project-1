### VM Creation
### Eric Caverly
### October 26th

### Inpsired by https://www.youtube.com/watch?v=v45SQwvho94

param ($USER, $VMname)

$PATH = "\\$HVserver\VMstorage"
$VMPATH = "$PATH\$USER\$VMname"

$image = "$PATH\isos\tiny10.iso"
$vmswitch = "vswitch1"
$port = "port1"
$cpu = 2
$ram = 4GB
$disksize = 15GB


New-Item -Path "$PATH\$USER" -Name "$VMname" -ItemType "directory"

New-VM $VMname
Set-VM $VMname -ProcessorCount $cpu -MemoryStartupBytes $ram
New-VHD -Path $VMPATH