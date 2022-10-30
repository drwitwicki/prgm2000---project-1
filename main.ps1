### Menu
### Eric Caverly & Dave Witwicki
### October 19th, 2022

### Global Variables (Computer Names)

$DCName = "D-DC01"

# Navigate into root; required so that menu.ps1, README.md, and any other files in the repo don't appear in the menu.
[String]$global:TopPath = Get-Location
$global:PATH="$global:TopPath\root"
cd $PATH

. "$TopPath/functions.ps1"

Function Check-Option($Opt, $contArray) {	
	if ($Opt -eq "u") {					# Up function (going up in directory structure)
		cd ..
		[String]$global:PATH = Get-Location
	} else {							# Starting a script or going deeper in the directory structure
		Go-Into $contArray[$Opt-1]
	} 

}

Function Go-Into($name) {				
	if ((Get-Item $name) -is [System.IO.DirectoryInfo]) {		# If the selected option is a directory, change into it
		Set-Location $name 								# Change into it and update the current path
		[String]$global:PATH = Get-Location
	} else {													# If it's a PS script, run it
		. "$global:PATH/$name"
	} 	
}

$running = $True
While ($running) {												# Repeat to make the menu interactive
	$contents = Get-ChildItem | Select-Object -ExpandProperty Name 	# Obtain the contents of the current directory
	$contArray = @($contents)

	$opt = @()
	if($global:PATH.substring($global:PATH.length-4) -ne "root") {		# Only give the option to move "up" when below root
		$opt+=,@("Up", "u")
	}
	for ($i=1; $i -le $contArray.length; $i++) {			# Add contents to the menu that do not have a "." infront of them (These should be hidden)
		$item= $contArray[$i-1]
		if ($item[0] -ne ".") {
			$opt+=,@("$item", "$i")
		}
	}		
	$ShortPath = $global:PATH.Substring($global:TopPath.length)		# Get the shortpath, will be shown in the menu as a reference and doesn't need to be a full path

	$Option = Build-Menu "Script Sel" $ShortPath $opt

	Check-Option $Option $contArray

	#Show-Message "WAIT" blue
}