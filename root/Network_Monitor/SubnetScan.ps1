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

Function Get-BinNetworkAndMask($argnetwork, $argmask) {
	$net = $argnetwork.split(".")
	
	$netBin = ""
	$masBin = ""
	
	for($i=0; $i -lt 4; $i++) {
		$netBin+=[convert]::ToString($net[$i], 2).PadLeft(8, '0')
	}

	$masbin+="1"*($argmask)
	$masbin+="0"*(32-$argmask)

	return $netBin, $masBin
}

Function Get-DecNetwork($argnetwork) {
	$net = @($argnetwork.substring(0, 8), $argnetwork.substring(8, 8), $argnetwork.substring(16, 8), $argnetwork.substring(24, 8))
	foreach $octet in $net {
		$octet = [Convert]::ToInt32($octet, 2)
	}
	$addr 
}

Function Current() {
	
}

Function Custom() {
	[string]$Network = Read-Host "Network (192.168.0.0) "
	[string]$SubnetMask = Read-Host "Subnet (255.255.255.0) "	

	$netbin, $masbin = Get-BinNetworkAndMask $Network $SubnetMask
	$netdec = Get-DecNetwork $netbin
	echo $netbin
	echo $masbin
	echo $netdec
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

