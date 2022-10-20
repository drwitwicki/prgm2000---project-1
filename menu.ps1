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

Function Build-Menu([Array[]]$contArray) {
	Clear-Host
	Write-Host -fore yellow "################################"
	
	$ShortPath = $global:PATH.Substring($TopPath.length)
	Write-Host -fore cyan "`n $ShortPath `n"
	
	for ($i=1; $i -le $contArray.length; $i++) {
		$item= $contArray[$i-1]
		Write-Host "$i -- $item"
	}

	Write-Host "`nu -- Up"
	Write-Host "q -- Quit"

	$Option = Read-Host "`nSelect (eg. '1')"

	return $Option
}


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

	$Option = Build-Menu $contArray
	Check-Option $Option $contArray
}




