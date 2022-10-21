### Subnet scan

. .\functions.ps1

<#
$ValidMaskChunks = @("254", "252", "248", "240", "224", "192", "128", "0")

Function SubnetScan($network, $mask) {
	$net = $network.split(".")
	$mas = $mask.split(".")

	$StartOfNet = $net

	for ($i=0; $i -lt 4; $i++) {
		if($ValidMaskChunks.contains($mas[$i])) {
			echo "found"
			$NumOfHosts = 255-[int]$mas[$i]
			for ($j=0; $j -lt 255; $j+=$NumOfHosts) {
				$j
				$NumOfHosts
				if( $net[$i] -ge $j -and $net[$i] -le $j) {
					$StartOfNet[$i] = $j
				}
			}
			
			$max = [int]$StartOfNet[$i]+[int]$NumOfHosts

			for ($k=[int]$StartOfNet[$i]; $k -le $max; $k++) {
				$addr = $StartOfNet
				$addr[$i] = $k
				$addr = $addr -join "."
				$addr
				ping $addr /n 1 /w 3 | Where -filter {$_ -match "Reply"}
			} 

			break
		}
	}

	Show-Error ""
} #>

Function SubnetScan($argnetwork, $argmask) {
	$net = $argnetwork.split(".")
	$mas = $argmask.split(".")
	
	for($i=0; $i -lt 4; $i++) {
		
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

