### Menu
### Eric Caverly & Dave Witwicki
### October 19th, 2022

$PATH = Get-Location
$contents = ls $PATH
$level = 0

if ($contents -contains "root") {
    $level = 0
}

Write-Host $contents

#$Option = Read-Host 
