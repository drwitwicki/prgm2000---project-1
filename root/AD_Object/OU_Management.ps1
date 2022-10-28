### View/Create/Delete Organizational Unit
### Eric Caverly & Dave Witwicki
### October 19th, 2022

#
function CreateOU($ADOUPath) {
	# Get OU to be created
	Write-Host "Input OU Name`n" -ForegroundColor Green
	$ADOUName = Read-Host -Prompt ">"
	# Create the specified OU
	if ($ADOUPath -eq "delta.local") {
		Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
			param ($ADOUName, $ADOUPath)
			New-ADOrganizationalUnit -Name $ADOUName
		} -ArgumentList $ADOUName, $ADOUPath
	}
	else {
		Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock { 
			param ($ADOUName, $ADOUPath)
			New-ADOrganizationalUnit -Name $ADOUName -Path "$ADOUPath"
		} -ArgumentList $ADOUName, $ADOUPath
	}
}

#
function DeleteOU($ADOUPath) {
}

$running = $true

while ($running) {
	$contents = Get-ADOrganizationalUnit -Properties CanonicalName -Filter * | Sort-Object CanonicalName | Select-Object -ExpandProperty CanonicalName
	$contArray = @($contents)
	$contents2 = Get-ADOrganizationalUnit -Properties DistinguishedName -Filter * | Sort-Object DistinguishedName | Select-Object -ExpandProperty DistinguishedName
	$contArray2 = @($contents2)

	$opt = @()
	$opt += (Get-ADDomain).Forest
	for ($i = 0; $i -le $contArray.length; $i++) {
		$item = $contArray[$i]
		$opt += , @("$item", "$i")
	}

	$sel = Build-Menu "Organizational Units" "select OU to modify" $opt

	$opt2 = @()
	$opt2 += , @("Create OU", 1)
	$opt2 += , @("Delete OU", 2)

	$sel2 = Build-Menu "OU Management" "select function" $opt2

	switch ($sel2) {
		1 {CreateOU($contArray2[$sel])}
		2 {DeleteOU($contArray2[$sel])}
	}
   
	Show-Message "Completed" Blue

}