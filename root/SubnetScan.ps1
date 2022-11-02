### Subnet scan
### Eric Caverly
### November 1st, 2022

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

Function Increment-Address($addr) {
	$tmp = [Convert]::ToInt64($addr, 2)			# Convert the binary version to one big decimal number
	$tmp += 1  						# Increase the number by one
	$addr = [Convert]::ToString($tmp, 2).PadLeft(32, "0") 	# Convert the huge number back to binary

	return $addr
}
	
Function Scan($binnet, $binmas, $slashmask) {					# Actual scan function of the subnet 
	$StartOfNetwork = Get-StartOfNetwork $binnet $binmas 		# Figure out which address to start from
	$NumOfHosts = [Math]::Pow(2, 32-$slashmask)-1 				# Figure out how many addresses are in the given subnet
	
	$addr = $StartOfNetwork
	[System.Collections.ArrayList]$jobs = @()
	$reachable = @()
	for ($i=0; $i -lt $NumOfHosts; $i+=6) {			# For each host in the subnet, start a 6 address chunk
		$decaddrlist = @()
		for($k=0; $k -lt 6; $k++) {					# Generate the chunk addresses, but don't go above the specified subnet
			if($i+$k -ge $NumOfHosts ) { break } 
			$decaddrlist += (Get-DecNetwork $addr) 			# Get the decimal version of each address
			$addr = Increment-Address $addr			
		}
		$jobs += Start-Job -ScriptBlock {					# Start the chunk job, adding it to the array of jobs
			param (
				$decaddrlist,
				$i
			)
			$result = @()
			foreach($addr in $decaddrlist) {				# For each address in the chunk
				if(Test-Connection $addr -Count 2 -TimeoutSeconds 1 -BufferSize 1 -quiet) {		# Send 2 ICMP echos
					try {																		# If a reply is received, try to resove it with DNS
						$hostname = [System.Net.Dns]::getHostByAddress($addr).Hostname
					} catch {
						$hostname = ""
					}
					$index = [string]$i 												# Add the pingable address to results, include its chunk number (i)
					$index = $index.PadLeft(5, '0')
					$result+=("$index`:   $addr -- Exists ==> $hostname")
				} #else { $result+="$addr doesnt exist`n" } 	
			}
			if($result.length -gt 0) {				# if the chunk was able to ping anything, combine the output into a string seperated by new lines and output it
				$output = $result -join("`n")
				$output
			}
		} -ArgumentList @($decaddrlist), $i

											# Show which addresses are being pinged
		Write-Host "Pinging $decaddrlist" -fore yellow
		
		if ($Host.UI.RawUI.KeyAvailable -and ($Host.UI.RawUI.ReadKey("IncludeKeyUp,NoEcho").Character -eq "q")) { break }		# if the 'q' key was pressed exit the loop (Written by Richard Giles  -- https://community.idera.com/database-tools/powershell/ask_the_experts/f/learn_powershell_from_don_jones-24/8696/problem-with-ending-a-loop-on-keypress)
	}

	while ($jobs.length -gt 0) {		# Once all jobs have been created, iterate through them
		foreach($job in $jobs) {
			$state = $job | get-job | select-object -expandproperty state 	
			if($state -eq "Completed") {			# if the currently selected job is completed
				$output = Receive-Job $job -keep	# Receive it's output and append it to the reachable array, then remove it from the jobs array
				$reachable += $output
				$jobs.remove($job)
				break						# Loop must be broken cause the jobs array has been modified
			} 
		}
	}
	$reachable = $reachable | sort 				# Sort the array so the addresses are in order
	[string]$disp = $reachable -join("`n") 		# Join the chunk's output together
	Clear-Host									# Show final status, without 'current address'
	Write-Host "Reachable IP addresses in subnet:" -Fore Cyan
	Write-Host "$disp" -Fore Green

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


Function Get-CurrentSubnet() {						# Find the current IP address of the system
	$info = Get-NetIPAddress -AddressFamily IPV4				# Only supported on windows
	$addr = @($info | Select-Object -expandproperty IPAddress)			# Get all IP addresses of all nics on the system
	$mask = @($info | Select-Object -expandproperty PrefixLength)		# Get the subnet mask of all nics on the system

	$opt2 = @()
	for ($i = 0; $i -lt $addr.length; $i++) {	# Build another menu asking the user to select the network they wish to scan
		$content = $addr[$i]+"/"+$mask[$i]	# Required since every PC has loopback, and a server might have more than one NIC
		$opt2 +=,@("$content", $i)
	}

	$sel2 = Build-Menu "Subet Scan" "Select Network" $opt2				# Menu for selecting network

	$netbin, $masbin = Get-BinNetworkAndMask $addr[$sel2] $mask[$sel2]		# Conver the chosen IP and Mask to binary
	Scan $netbin $masbin $mask[$sel2]						# Scan the chosen network
}

Function Get-CustomSubnet() {			# Manually entered IP and mask, doesn't have to be the subnet the executing machine is on
	$takingInput = $TRUE
	while ($takingInput) {
		[string]$Network = Read-Host "Network (192.168.0.0) "		# Obtain information from user
		[string]$SubnetMask = Read-Host "Subnet (24) "	

		$reason = Check-Input $Network $SubnetMask			# Verify information provided is valid

		if($reason.length -eq 13) {												# if the information is valid (reason hasn't grown in size)
			$takingInput = $FALSE
			$netbin, $masbin = Get-BinNetworkAndMask $Network $SubnetMask	# Convert the information to binary
			Scan $netbin $masbin $SubnetMask				# Scan the network
		} else {						# If the information is not valid, tell the user why
			Show-Message $reason red	
		}
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
