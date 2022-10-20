### Menu
### Eric Caverly & Dave Witwicki
### October 19th, 2022

# Display the banner when the program is ran
$banner = "
Administrative Tasks Menu
By Eric & David
"
Write-Host -fore yellow "################################"
Write-Host -fore cyan $banner

# Navigate into root; required so that menu.ps1, README.md, and any other files in the repo don't appear in the menu.
[String]$TopPath = Get-Location
$global:PATH="$TopPath/root"
cd $PATH

$global:running = $True

. "$TopPath/functions.ps1"

Function Check-Option($Opt, $contArray) {
	if ($Opt -eq "q") {
		$global:running = $False
	} 
	
	elseif ($Opt -eq "u") {
		if($global:PATH.substring($global:PATH.length-4) -ne "root"){
			cd ..
			[String]$global:path = Get-Location
		} else {
			Show-Error("Unable to move up, at root!")
		}
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
		[String]$global:path = Get-Location
	}
	
	elseif ($Ext -eq ".ps1") {
		. "$global:PATH/$name"
		Show-Error ""
	} 
	
	else {
		Show-Error "Illegal file type!"
	}
}

Function Show-Error($Message) {
	Write-Host -fore red "`n    $Message `n"
	Write-Host "Press any key to continue..."
	$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}


While ($running) {
	$contents = ls
	$contArray = $contents -split " "

	#$Option = Legacy-Build-Menu $contArray

	$opt = [System.Collections.ArrayList]
	for ($i=1; $i -le $contArray.length; $i++) {
		$item= $contArray[$i-1]
		$opt.add(("$item", "$i"))
	}

	echo $opt
	$opt.add(("Quit", "q"))
	$opt.add(("Up", "u"))

	echo $opt
	
	$ShortPath = $global:PATH.Substring($TopPath.length)


	Check-Option $Option $contArray
}




