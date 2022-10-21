### Subnet scan

Function SubnetScan($network, $mask) {

	$network

	$net = $network -split "."
	$mas = $mask -split "."

	Show-Error ""
}

Function Current() {
	
}

Function Custom() {
	[string]$Network = Read-Host "Network (192.168.0.0) "
	[string]$SubnetMask = Read-Host "Subnet (255.255.255.0) "	

	echo $Network
	$Network = $Network -split "."
	Write-Host $Network | gm
	Write-Host $Network

	SubnetScan $Network $SubnetMask
}

$opt = @()
$opt+=,@("Current Subnet", 1)
$opt+=,@("Custom Subnet", 2)
$opt+=,@("Exit", 3)

$sel = Build-Menu "Subnet Scan" "Select Function" $opt

switch ($sel) {
	1 { Current }
	2 { Custom }
}
