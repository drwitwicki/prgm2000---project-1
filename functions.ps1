### Functions File
### Eric Caverly
### Octover 20th, 2022

Function Legacy-Build-Menu([Array[]]$contArray) {
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

Function Build-Menu($title, $subtitle, [Array[]]$options) {
	
}
