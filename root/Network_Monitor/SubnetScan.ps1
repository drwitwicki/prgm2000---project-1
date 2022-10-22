### Subnet scan

. .\functions.ps1

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
	$decnet =@(0,0,0,0)
	for($i=0; $i -lt 4; $i++) {
		$decnet[$i] = [Convert]::ToInt32($net[$i], 2)
	}
	$addr = $decnet -join "."
	return $addr
}

Function Get-StartOfNetwork($binnet, $binmas) {
	$StartOfNetwork = ""
	for ($i=0; $i -lt 32; $i++) {
		if($binnet[$i] -eq "1" -and $binmas[$i] -eq "1") {
			$StartOfNetwork+=1
		} else {
			$StartOfNetwork+=0
		}
	}
	return $StartOfNetwork
}


Function Scan($binnet, binmas) {
	$StartOfNetwork = Get-StartOfNetwork $binnet $binmas
	
}


Function Get-Current() {
	
}

Function Get-Custom() {
	[string]$Network = Read-Host "Network (192.168.0.0) "
	[string]$SubnetMask = Read-Host "Subnet (255.255.255.0) "	

	$netbin, $masbin = Get-BinNetworkAndMask $Network $SubnetMask
	Scan $netbin $masbin
}

$opt = @()
$opt+=,@("Current Subnet", 1)
$opt+=,@("Custom Subnet", 2)
$opt+=,@("Exit", 3)

$sel = Build-Menu "IPv4 Subnet Scan" "Select Function" $opt

switch ($sel) {
	1 { Get-Current }
	2 { Get-Custom }
}

