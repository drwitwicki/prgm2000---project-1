### Subnet scan

$ValidMaskChunks = @(254, 252, 248, 240, 224, 192, 128, 0)

Function SubnetScan($network, $mask) {

	$net = $network.split(".")
	$mas = $mask.split(".")


	for ($i=0; $i -lt 4; $i++) {
		if( $mas[$i} -ne 255 -and $mas[$i] -match $ValidMaskChunks) {
			$NumOfHosts = 255-$mas[$i]
			for ($j=0; $j -lt 255; $j+=$NumOfHosts) {
				if( $net[$i] -ge $j -and $net[$i] -le $j) {
					$StartOfNet = $j
					break
				}
			}
			

			for ($k=$StartOfNet; $k -le $StartOfNet+$NumOfHosts; $k++) {
				### Do this address
				### Do all addresses (254) in the next octet	
			}

			break
		} else {
			Show-Error "Incorrect Mask"
		}
	}
}

Function Current() {
	
}

Function Custom() {
	[string]$Network = Read-Host "Network (192.168.0.0) "
	[string]$SubnetMask = Read-Host "Subnet (255.255.255.0) "	

	SubnetScan $Network $SubnetMask
}

$opt = @()
$opt+=,@("Current Subnet", 1)
$opt+=,@("Custom Subnet", 2)
$opt+=,@("Exit", 3)

$sel = Build-Menu "IPv4 Subnet Scan" "Select Function" $opt

switch ($sel) {
	1 { Current }
	2 { Custom }
}
