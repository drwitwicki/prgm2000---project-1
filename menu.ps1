### Menu
### Eric Caverly & Dave Witwicki
### October 19th, 2022

# Display the banner when the program is ran
$banner = "
######################

Administrative Tasks Menu
By Eric & David

######################
"
Write-Host $banner

# Navigate into root; required so that menu.ps1, README.md, and any other files in the repo don't appear in the menu.
$PATH = Get-Location
$PATH="$PATH/root"
cd $PATH


$running = $True

Function Build-Menu([Array[]]$contArray) {
	for ($i=1; $i -le $contArray.length; $i++) {
		$item= $contArray[$i-1]
		Write-Host "$i -- $item"
	}

	Write-Host "q -- Quit"

	$Option = Read-Host "`nSelect (eg. '1')"

	return $Option
}


Function Check-Option($Opt) {
	if ($Opt -eq "q") {
		$running = $False
	}	
}


While ($running) {
	$contents = ls
	$contArray = $contents -split " "

	$Option = Build-Menu contArray
	Check-Option $Option
}




