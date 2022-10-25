### Functions File
### Eric Caverly
### Octover 20th, 2022

$global:pos = 0

. "$TopPath/bigtext.ps1"

Function Build-Menu($title, $subtitle, [Array[]]$options) {
	$gettingSelection = $True
	while($gettingSelection) {
		Clear-Host

		Write-Host -fore yellow "#####################################"
		#Write-Host -fore cyan "`n $title"
		$titleText = Convert-Lorge $title
		Write-Host -fore cyan $titleText[0]
		Write-Host -fore cyan $titleText[1]
		Write-Host -fore cyan $titleText[2]


		Write-Host -fore magenta "`n $subtitle `n"

		for ($i=0; $i -lt $options.length; $i++) {
			if($i -eq $global:pos) {
				Write-Host -fore green " >  $($options[$i][0])"
			} else {
				Write-Host -fore gray "    $($options[$i][0])"

			}
		}	
	
		Write-Host "`n`n(up / down / enter / q)`n"
		Write-Host -fore yellow "#####################################"

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

Function Show-Message($Message, $Color) {
	Write-Host -fore $Color "`n    $Message `n"
	Write-Host "Press any key to continue..."
	$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}
