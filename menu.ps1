### Menu
### Eric Caverly & Dave Witwicki
### October 19th, 2022

# Navigate into root; required so that menu.ps1, README.md, and any other files in the repo don't appear in the menu.
$PATH = Get-Location
$PATH="$PATH/root"
cd $PATH

$contents = ls
$contArray = $contents -split " "

for ($i=1; $i -le $contArray.length; $i++) {
	$item= $contArray[$i-1]
	Write-Host "$i -- $item"
}

$Option = Read-Host 
