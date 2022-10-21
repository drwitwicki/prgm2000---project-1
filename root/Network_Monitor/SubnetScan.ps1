### Subnet scan

Function SubnetScan() {
	
}

Function Current() {
	
}

Function Custom() {

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
