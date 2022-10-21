### Menu
### Eric Caverly & Dave Witwicki
### October 19th, 2022

# Navigate into root; required so that menu.ps1, README.md, and any other files in the repo don't appear in the menu.
[String]$global:TopPath = Get-Location
$global:PATH="$global:TopPath/root"
cd $PATH

$global:running = $True

. "$TopPath/functions.ps1"

Function Check-Option($Opt, $contArray) {	
	if ($Opt -eq "u") {
		cd ..
	}
	
	elseif ( ($Opt -match "[0-9]") -and ($Opt -gt 0) -and ($Opt -lt $contArray.length+1)) {
		Go-Into $contArray[$Opt-1]
	} 

	else {
		Show-Error("Illegal Operation")
	}
}

Function Go-Into($name) {
	[String]$Ext = Get-Item $name | Select-Object -expandproperty Extension
	
	if ($Ext -eq "") {
		cd $name
		[String]$global:PATH = Get-Location
	}
	
	elseif ($Ext -eq ".ps1") {
		. "$global:PATH/$name"
	} 
	
	else {
		Show-Error "Illegal file type!"
	}
}


While ($running) {
	$contents = ls
	$contArray = $contents -split " "

	$opt = @()
	if($global:PATH.substring($global:PATH.length-4) -ne "root") {
		$opt+=,@("Up", "u")
	}
	for ($i=1; $i -le $contArray.length; $i++) {
		$item= $contArray[$i-1]
		$opt+=,@("$item", "$i")
	}		
	$ShortPath = $global:PATH.Substring($global:TopPath.length)

	$Option = Build-Menu "Select a script" $ShortPath $opt

	Check-Option $Option $contArray
}




