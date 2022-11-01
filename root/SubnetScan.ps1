### Subnet scan
### Eric Caverly
### October 21st, 2022

Function Get-BinNetworkAndMask($argnetwork, $argmask) {		# Convert a decimal network address and slash notation mask to binary
	$net = $argnetwork.split(".")					# Turn the string of octets into an array
	
	$netBin = ""
	$masBin = ""
	
	for($i=0; $i -lt 4; $i++) {						# For each octet, convert it to binary and add it to the string
		$netBin+=[convert]::ToString($net[$i], 2).PadLeft(8, '0')
	}

	$masbin+="1"*($argmask)							# Convert the slash to binary
	$masbin+="0"*(32-$argmask)

	return $netBin, $masBin
}

Function Get-DecNetwork($argnetwork) {				# Convert a binary ip address to decimal
	$net = @($argnetwork.substring(0, 8), $argnetwork.substring(8, 8), $argnetwork.substring(16, 8), $argnetwork.substring(24, 8))  # split the 32 character long binary address into an array of 4, 8 char long sections
	$decnet =@(0,0,0,0)
	for($i=0; $i -lt 4; $i++) {						# Convert each 8 char long section to decimal, and set the point in the array above to it
		$decnet[$i] = [Convert]::ToInt32($net[$i], 2)
	}
	$addr = $decnet -join "."						# Convert the array into a string, each item seperated by a .
	return $addr
}

Function Get-StartOfNetwork($binnet, $binmas) {		# Find the first IP address in the network of the IP specified
	$StartOfNetwork = ""
	for ($i=0; $i -lt 31; $i++) {					# For 31 out of 32 characters in the binary mask, perform a binary and operation
		if($binnet[$i] -eq "1" -and $binmas[$i] -eq "1") {
			$StartOfNetwork+=1
		} else {
			$StartOfNetwork+=0
		}
	}
	$StartOfNetwork+="1"		# Add a one at the end to ensure the result in the first IP and not the network address
	return $StartOfNetwork
}

Function Scan($binnet, $binmas, $slashmask) {					# Actual scan function of the subnet 
	$StartOfNetwork = Get-StartOfNetwork $binnet $binmas 		# Figure out which address to start from
	$NumOfHosts = [Math]::Pow(2, 32-$slashmask)-1 				# Figure out how many addresses are in the given subnet
	
	$addr = $StartOfNetwork
	Write-Host "Press 'q' to stop the scan" -fore Yellow 									
	for ($i=0; $i -lt $NumOfHosts; $i++) {			# For each host in the subnet
		$decaddr = Get-DecNetwork $addr 			# Get the decimal version of its address
		
		Write-Host $decaddr
		if($IsWindows) {							# Ping the decimal version of the address, different operating systems have different syntax since PING is not a powershell CMDlet
			ping $decaddr /n 1 /w 2 | Where-Object -filter {$_ -match "Reply"}
		} else {
			ping $decaddr -c 1 -W 2 | Where-Object -filter {$_ -match "from"}
		}


		$tmp = [Convert]::ToInt64($addr, 2)						# Convert the binary version to one big decimal number
		$tmp += 1  												# Increase the number by one
		$addr = [Convert]::ToString($tmp, 2).PadLeft(32, "0") 	# Convert the huge number back to binary
		
		if ($Host.UI.RawUI.KeyAvailable -and ($Host.UI.RawUI.ReadKey("IncludeKeyUp,NoEcho").Character -eq "q")) { break }		# if the 'q' key was pressed exit the loop (Written by Richard Giles  -- https://community.idera.com/database-tools/powershell/ask_the_experts/f/learn_powershell_from_don_jones-24/8696/problem-with-ending-a-loop-on-keypress)
	}

	Show-Message "Completed" blue
}

Function Check-Input($netw, $mask) {
	$reason = "INPUT ERROR: "
	$net = $netw.split(".")							# Function of each check described by error message
	if ($net.length -ne 4) { $reason += "Number of octets other than 4 detected, "}
	foreach ($octet in $net) {
		if ($octet -notmatch "^\d+$") { $reason += "Octet other than number detected (0-255), "; continue}
		if([int]$octet -lt 0 -or [int]$octet -gt 255) { $reason += "Invalid octet number (0-255), "}
	}
	if ($mask -notmatch "^\d+$") {
		$reason += "Invalid mask (non-number input detected), "
	} elseif ([int]$mask -gt 32 -or [int]$mask -lt 0) {
		$reason += "Invalid mask (number must be between 0 and 32), "
	}

	return $reason
}


Function Get-CurrentSubnet() {										# Find the current IP address of the system
	$info = Get-NetIPAddress -AddressFamily IPV4				# Only supported on windows
	$addr = @($info | Select-Object -expandproperty IPAddress)			# Get all IP addresses of all nics on the system
	$mask = @($info | Select-Object -expandproperty PrefixLength)		# Get the subnet mask of all nics on the system

	$opt2 = @()
	for ($i = 0; $i -lt $addr.length; $i++) {					# Build another menu asking the user to select the network they wish to scan
		$content = $addr[$i]+"/"+$mask[$i]						# Required since every PC has loopback, and a server might have more than one NIC
		$opt2 +=,@("$content", $i)
	}

	$sel2 = Build-Menu "Subet Scan" "Select Network" $opt2			# Menu for selecting network

	$netbin, $masbin = Get-BinNetworkAndMask $addr[$sel2] $mask[$sel2]		# Conver the chosen IP and Mask to binary
	Scan $netbin $masbin $mask[$sel2]										# Scan the chosen network
}

Function Get-CustomSubnet() {										# Manually entered IP and mask, doesn't have to be the subnet the executing machine is on
	[string]$Network = Read-Host "Network (192.168.0.0) "		# Obtain information from user
	[string]$SubnetMask = Read-Host "Subnet (24) "	

	$reason = Check-Input $Network $SubnetMask			# Verify information provided is valid

	if($reason.length -eq 13) {												# if the information is valid (reason hasn't grown in size)
		$netbin, $masbin = Get-BinNetworkAndMask $Network $SubnetMask	# Convert the information to binary
		Scan $netbin $masbin $SubnetMask								# Scan the network
	} else {													# If the information is not valid, tell the user why
		Show-Message $reason red
		Get-Custom
	}
}

$opt = @()
$opt+=,@("Current Subnet", 1)
$opt+=,@("Custom Subnet", 2)
$opt+=,@("Exit", 3)

$sel = Build-Menu "Subnet Scan" "Select Function" $opt

switch ($sel) {
	1 { Get-CurrentSubnet }
	2 { Get-CustomSubnet }
}