### Create/Delete OUs
### Eric Caverly & Dave Witwicki
### October 19th, 2022

$DCName = "D-DC01"

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

function ViewGroups($ADOUPath) {
	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		param($ADOUPath)
		Get-ADGroup -Filter * -SearchBase $ADOUPath
	} -ArgumentList $ADOUPath
}

function CreateGroup($ADOUPath) {
	Write-Host "Input Group Name (create)`n" -ForegroundColor Green
	$GroupName = Read-Host -Prompt ">"

	$ScopeOpt = @()
	$ScopeOpt += , @("Domain Local", 1)
	$ScopeOpt += , @("Global", 2)
	$ScopeOpt += , @("Universal", 3)

	$ScopeSel = Build-Menu "AD Groups" "select a scope" $ScopeOpt

	switch ($ScopeSel) {
		1 {$GroupScope = "DomainLocal"}
		2 {$GroupScope = "Global"}
		3 {$GroupScope = "Universal"}
	}

	$CatOpt = @()
	$CatOpt += , @("Distribution", 1)
	$CatOpt += , @("Security", 2)

	$CatSel = Build-Menu "AD Groups" "select a category" $CatOpt

	switch ($CatSel) {
		1 {$GroupCategory = "Distribution"}
		2 {$GroupCategory = "Security"}
	}

	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		param($ADOUPath, $GroupName, $GroupScope, $GroupCategory)
		New-ADGroup -Name $GroupName -GroupCategory $GroupCategory -GroupScope $GroupScope -Path $ADOUPath -Description "created by script"
	}
}

function DeleteGroup() {
	Write-Host "Input Group Name (delete)`n" -ForegroundColor Green
	$GroupName = Read-Host -Prompt ">"

	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		param($GroupName)
		Remove-ADGroup -Identity $GroupName
	} -ArgumentList $GroupName
}

function CreateUser($ADOUPath) {
	Write-Host "Input User Name (create)`n" -ForegroundColor Green
	$UserName = Read-Host -Prompt ">"
	Write-Host "Input Password`n" -ForegroundColor Green
	$UserPassword = Read-Host -Prompt ">"

	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		param($ADOUPath, $UserName, $UserPassword)
		New-ADUser -Name $UserName -AccountPassword $UserPassword -Path $ADOUPath -Enabled $true
	} -ArgumentList $ADOUPath, $UserName, $UserPassword
}

function DeleteUser() {
	Write-Host "Input User Name (delete)`n" -ForegroundColor Green
	$UserName = Read-Host -Prompt ">"

	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		param($UserName)
		Remove-ADUser -Identity $UserName
	} -ArgumentList $UserName
}

function DisableUser() {
	Write-Host "Input User Name (disable)`n" -ForegroundColor Green
	$UserName = Read-Host -Prompt ">"

	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		param($UserName)
		Disable-ADAccount -Identity $UserName
	} -ArgumentList $UserName
}

function UnlockUsers() {
	Write-Host "Account Unlocker`n`n" -ForegroundColor Green
	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		Search-ADAccount -LockedOut | Unlock-ADAccount -Confirm
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
	for ($i = 0; $i -lt $CanonicalNamesArray.length; $i++) {
		$item = $CanonicalNamesArray[$i]
		$opt += , @("$item", "$i")
	}

	$sel = Build-Menu "Active Directory" "select OU to modify" $opt

	$opt2 = @()
	$opt2 += , @("Create OU", 1)
	$opt2 += , @("Delete OU", 2)
	$opt2 += , @("View Groups", 3)
	$opt2 += , @("Create Group", 4)
	$opt2 += , @("Delete Group", 5)

	$sel2 = Build-Menu "Active Directory" "select function" $opt2

	switch ($sel2) {
		1 {CreateOU($DistinguishedNamesArray[$sel])}
		2 {DeleteOU($DistinguishedNamesArray[$sel])}
		3 {ViewGroups($DistinguishedNamesArray[$sel])}
		4 {CreateGroup($DistinguishedNamesArray[$sel])}
		5 {DeleteGroup}
	}
   
	Show-Message "Completed" Blue

}