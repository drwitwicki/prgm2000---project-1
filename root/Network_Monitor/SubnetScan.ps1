### Subnet scan
### Eric Caverly
### October 21st, 2022

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
	for ($i=0; $i -lt 31; $i++) {
		if($binnet[$i] -eq "1" -and $binmas[$i] -eq "1") {
			$StartOfNetwork+=1
		} else {
			$StartOfNetwork+=0
		}
	}
	$StartOfNetwork+="1"
	return $StartOfNetwork
}


Function Scan($binnet, $binmas, $slashmask) {
	$StartOfNetwork = Get-StartOfNetwork $binnet $binmas
	$NumOfHosts = [Math]::Pow(2, 32-$slashmask)-1
	
	$addr = $StartOfNetwork
	for ($i=0; $i -lt $NumOfHosts; $i++) {
		$decaddr = Get-DecNetwork $addr
		
		Write-Host $decaddr
		if($IsWindows) {
			ping $decaddr /n 1 /w 2 | Where -filter {$_ -match "Reply"}
		} else {
			ping $decaddr -c 1 -W 1 | Where -filter {$_ -match "from"}
		}


		$tmp = [Convert]::ToInt64($addr, 2)
		$tmp += 1
		$addr = [Convert]::ToString($tmp, 2).PadLeft(32, "0")
		
	}
}

Function Check-Input($netw, $mask) {
	$proper = $True
	$net = $netw.split(".")
	if($net.length -ne 4) { $proper = $False }
	if(($net -join "") -notmatch "[0-9]") { $proper = $False }
	if($mask -notmatch "[0-9]") { $proper = $False }

	return $proper
}


Function Get-Current() {
	$info = Get-NetIPAddress -AddressFamily IPV4
	$addr = @($info | Select-Object -expandproperty IPAddress)
	$mask = @($info | Select-Object -expandproperty PrefixLength)

	for 
	Show-Message "Completed" blue
}

Function Get-Custom() {
	[string]$Network = Read-Host "Network (192.168.0.0) "
	[string]$SubnetMask = Read-Host "Subnet (255.255.255.0) "	

	$proper = Check-Input $Network $SubnetMask

	if($proper) {
		$netbin, $masbin = Get-BinNetworkAndMask $Network $SubnetMask
		Scan $netbin $masbin $SubnetMask

		Show-Message "Completed" green
	} else {
		Show-Message "Invalid Input" red
		Get-Custom
	}
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

