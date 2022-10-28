### Create/Delete OUs and Groups
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
	if ($ADOUPath -eq (Get-ADDomain).DistinguishedName) {
		Write-Host "If you want the script that deletes the domain, you'll have to pay for the premium version" -ForegroundColor Red
	}
	else {
		Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
			param($ADOUPath)
			Set-ADObject -Identity $ADOUPath -ProtectedFromAccidentalDeletion:$false -PassThru
			Remove-ADOrganizationalUnit -Identity $ADOUPath -Confirm:$false
		} -ArgumentList $ADOUPath
	}
}

$running = $true

while ($running) {
	$CanonicalNamesArray = @()
	$CanonicalNamesArray += (Get-ADDomain).Forest
	$CanonicalNamesList = Get-ADOrganizationalUnit -Properties CanonicalName -Filter * | Select-Object -ExpandProperty CanonicalName

	foreach($name in $CanonicalNamesList) {
		$CanonicalNamesArray += $name
	}

	$DistinguishedNamesArray = @()
	$DistinguishedNamesArray += (Get-ADDomain).DistinguishedName
	$DistinguishedNamesList = Get-ADOrganizationalUnit -Properties DistinguishedName -Filter * | Select-Object -ExpandProperty DistinguishedName

	foreach($name in $DistinguishedNamesList) {
		$DistinguishedNamesArray += $name
	}

	$opt = @()
	# $opt += , @((Get-ADDomain).Forest, -1)
	for ($i = 0; $i -lt $CanonicalNamesArray.length; $i++) {
		$item = $CanonicalNamesArray[$i]
		$opt += , @("$item", "$i")
	}

	$sel = Build-Menu "OUs" "select OU to modify" $opt

	$opt2 = @()
	$opt2 += , @("Create OU", 1)
	$opt2 += , @("Delete OU", 2)

	$sel2 = Build-Menu "OU MGMT" "select function" $opt2

	switch ($sel2) {
		1 {CreateOU($DistinguishedNamesArray[$sel])}
		2 {DeleteOU($DistinguishedNamesArray[$sel])}
	}
   
	Show-Message "Completed" Blue

}