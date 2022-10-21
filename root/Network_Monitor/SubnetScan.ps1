### Subnet scan
Function Build-Menu($title, $subtitle, [Array[]]$options) {
	$gettingSelection = $True
	while($gettingSelection) {
		Clear-Host

		Write-Host -fore yellow "################################"
		Write-Host -fore cyan "`n $title `n"
		Write-Host -fore yellow "################################"
		Write-Host -fore magenta "`n $subtitle `n"

		for ($i=0; $i -lt $options.length; $i++) {
			if($i -eq $global:pos) {
				Write-Host -fore green " >  $($options[$i][0])"
			} else {
				Write-Host -fore gray "    $($options[$i][0])"

			}
		}	
	
		Write-Host "`n`n(⬆ /⬇ /↪ /q)"

		$key = $Host.UI.RawUI.ReadKey().virtualkeycode

		Switch($key) {
			13 { $output = $options[$global:pos][1]; $gettingSelection = $False; $global:pos=0}	# Enter
			38 { if($global:pos -gt 0) { $global:pos -= 1 } }	# Up
			40 { if($global:pos -lt $options.length-1) { $global:pos += 1} }	# Down 
			81 { exit }	# Q
		}
	}
	
	return $output

}

Function Show-Error($Message) {
	Write-Host -fore red "`n    $Message `n"
	Write-Host "Press any key to continue..."
	$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}


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
				ping $addr /n 1 /w 5 | Where -filter {$_ -match "Reply"}
			} 

			break
		}
	}

	Show-Error ""
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

