### Create/Delete OUs
### Eric Caverly & Dave Witwicki
### October 19th, 2022

# Hardcoded name for domain controller
$DCName = "D-DC01"

<#
.SYNOPSIS
Create Organizational Unit in desired location

.DESCRIPTION
Accepts user input for desired OU name and creates the OU in the desired path as specified in the prior selection menu.

.PARAMETER ADOUPath
DistinguishedName active directory path selected by the user
#>
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

<#
.SYNOPSIS
Delete desired Organizational Unit

.DESCRIPTION
Deletes the OU selected by the user in the prior selection menu. In order to ensure successful deletion, the script first removes accidental deletion protections, so use wisely.

.PARAMETER ADOUPath
DistinguishedName active directory path selected by the user
#>
function DeleteOU($ADOUPath) {
	# Don't delete anything if Domain Root is selected, that would be bad
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

<#
.SYNOPSIS
Displays AD User Groups

.DESCRIPTION
Using the ADOU Path selected by the user in the prior menu, displays all user groups contained within that scope. If the domain root is selected, should show all user groups on the domain.

.PARAMETER ADOUPath
DistinguishedName active directory path selected by the user
#>
function ViewGroups($ADOUPath) {
	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		param($ADOUPath)
		Get-ADGroup -Filter * -SearchBase $ADOUPath | Select-Object Name, GroupCategory, GroupScope | Format-Table
	} -ArgumentList $ADOUPath
}

<#
.SYNOPSIS
Creates AD User Groups

.DESCRIPTION
Prompts the user for the name of a new group, then presents a menu to select the group scope and group category. 

.PARAMETER ADOUPath
DistinguishedName active directory path selected by the user
#>
function CreateGroup($ADOUPath) {
	Write-Host "Input Group Name (create)`n" -ForegroundColor Green
	$GroupName = Read-Host -Prompt ">"

	$ScopeOpt = @()
	$ScopeOpt += , @("Domain Local", 1)
	$ScopeOpt += , @("Global", 2)
	$ScopeOpt += , @("Universal", 3)

	$ScopeSel = Build-Menu "AD Groups" "select a scope" $ScopeOpt

	switch ($ScopeSel) {
		1 {$GroupScope = 0}
		2 {$GroupScope = 1}
		3 {$GroupScope = 2}
	}

	$CatOpt = @()
	$CatOpt += , @("Distribution", 1)
	$CatOpt += , @("Security", 2)

	$CatSel = Build-Menu "AD Groups" "select a category" $CatOpt

	switch ($CatSel) {
		1 {$GroupCategory = 0}
		2 {$GroupCategory = 1}
	}

	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		param($ADOUPath, $GroupName, $GroupScope, $GroupCategory)
		New-ADGroup -Name $GroupName -GroupCategory $GroupCategory -GroupScope $GroupScope -Path $ADOUPath -Description "created by script"
	} -ArgumentList $ADOUPath, $GroupName, $GroupScope, $GroupCategory
}

<#
.SYNOPSIS
Delete AD Group

.DESCRIPTION
Prompts user for the identity of an existing active directory group, and then deletes it.
#>
function DeleteGroup() {
	Write-Host "Input Group Name (delete)`n" -ForegroundColor Green
	$GroupName = Read-Host -Prompt ">"

	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		param($GroupName)
		Remove-ADGroup -Identity $GroupName
	} -ArgumentList $GroupName
}

<#
.SYNOPSIS
Create AD User

.DESCRIPTION
Prompts user for the identity of a new user account, then creates it within the AD Path specified in the prior menu.

.PARAMETER ADOUPath
DistinguishedName active directory path selected by the user
#>
function CreateUser($ADOUPath) {
	Write-Host "Input User Name (create)`n" -ForegroundColor Green
	$UserName = Read-Host -Prompt ">"

	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		param($ADOUPath, $UserName)
		New-ADUser -Name $UserName -Path $ADOUPath -Enabled $true
	} -ArgumentList $ADOUPath, $UserName
}

<#
.SYNOPSIS
Delete AD User

.DESCRIPTION
Promps for the name of a user contained within active directory, then deletes it.
#>
function DeleteUser() {
	Write-Host "Input User Name (delete)`n" -ForegroundColor Green
	$UserName = Read-Host -Prompt ">"

	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		param($UserName)
		Remove-ADUser -Identity $UserName
	} -ArgumentList $UserName
}

<#
.SYNOPSIS
Disable AD User

.DESCRIPTION
Prompts for name of a user contained within active directory, then disables that account
#>
function DisableUser() {
	Write-Host "Input User Name (disable)`n" -ForegroundColor Green
	$UserName = Read-Host -Prompt ">"

	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		param($UserName)
		Disable-ADAccount -Identity $UserName
	} -ArgumentList $UserName
}

<#
.SYNOPSIS
View and unlock locked user accounts on active directory

.DESCRIPTION
Searches for all locked out accounts on the domain, and presents a prompt offering to unlock each one.
#>
function UnlockUsers() {
	Write-Host "Account Unlocker`n`n" -ForegroundColor Green
	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		Search-ADAccount -LockedOut | Unlock-ADAccount -Confirm
	}
}

<#
.SYNOPSIS
View most recent login time for a specfied user

.DESCRIPTION
Prompts for name of a user, then displays the most recent login time for that user
#>
function ViewLogon() {
	Write-Host "Input User Name (logon time)`n" -ForegroundColor Green
	$UserName = Read-Host -Prompt ">"

	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		param($UserName)
		Get-ADUser -Identity $UserName -Properties * | Select-Object LastLogonDate
	} -ArgumentList $UserName
}

<#
.SYNOPSIS
Views all unsuccessful logins on the domain

.DESCRIPTION
Searches all users on AD to find those with more than one failed login attempt, then displays pertinent information about those users, including the number of failed attempts and bad password entries.
#>
function ViewFailedLogon() {
	Write-Host "Unsuccessful Logins`n`n" -ForegroundColor Green
	Invoke-Command -ComputerName $DCName -Credential Delta\Administrator -ScriptBlock {
		Get-ADUser -Filter { badLogonCount -gt 1 } -Properties * | Select-Object ObjectClass, Name, Department, Title, badLogonCount, badPwdCount | Format-Table
	}
}

# run forever
$running = $true

while ($running) {
	# create array to contain user-readable OU names
	$CanonicalNamesArray = @()
	# first entry should be root name of the domain
	$CanonicalNamesArray += (Get-ADDomain -Server $DCName).Forest
	# get a list of all the user-readable OU names
	$CanonicalNamesList = Get-ADOrganizationalUnit -Server $DCName -Properties CanonicalName -Filter * | Select-Object -ExpandProperty CanonicalName

	# add the list of names to the proper array
	foreach($name in $CanonicalNamesList) {
		$CanonicalNamesArray += $name
	}

	# create an array to hold the distingushed names we need for our scripts to function properly
	$DistinguishedNamesArray = @()
	# first entry should be the domain root
	$DistinguishedNamesArray += (Get-ADDomain -Server $DCName).DistinguishedName
	# get a list of all the distinguished path names
	$DistinguishedNamesList = Get-ADOrganizationalUnit -Server $DCName -Properties DistinguishedName -Filter * | Select-Object -ExpandProperty DistinguishedName

	# add the list of distinguished name paths to the proper array
	foreach($name in $DistinguishedNamesList) {
		$DistinguishedNamesArray += $name
	}

	# takes the user-friendly canonical names and puts them in a new array that our menu function can display properly
	$opt = @()
	for ($i = 0; $i -lt $CanonicalNamesArray.length; $i++) {
		$item = $CanonicalNamesArray[$i]
		$opt += , @("$item", "$i")
	}

	# Start-Sleep -Seconds 10

	# call the menu that displays our entire active directory
	$sel = Build-Menu "Active Directory" "select OU to modify" $opt

	# build main function selection menu
	$opt2 = @()
	$opt2 += , @("Create OU", 1)
	$opt2 += , @("Delete OU", 2)
	$opt2 += , @("View Groups", 3)
	$opt2 += , @("Create Group", 4)
	$opt2 += , @("Delete Group", 5)
	$opt2 += , @("Create User", 6)
	$opt2 += , @("Delete User", 7)
	$opt2 += , @("Disable User", 8)
	$opt2 += , @("Unlock Users", 9)
	$opt2 += , @("View User Logon Time", 10)
	$opt2 += , @("View Failed Logins", 11)

	# call the menu that the user interacts with to select a program function
	$sel2 = Build-Menu "Active Directory" "select function" $opt2

	# choose a function depending on what selection the user made
	switch ($sel2) {
		1 {CreateOU($DistinguishedNamesArray[$sel])}
		2 {DeleteOU($DistinguishedNamesArray[$sel])}
		3 {ViewGroups($DistinguishedNamesArray[$sel])}
		4 {CreateGroup($DistinguishedNamesArray[$sel])}
		5 {DeleteGroup}
		6 {CreateUser($DistinguishedNamesArray[$sel])}
		7 {DeleteUser}
		8 {DisableUser}
		9 {UnlockUsers}
		10 {ViewLogon}
		11 {ViewFailedLogon}
	}
   
	# show something so the display doesn't immediately clear
	Show-Message "Completed" Blue

}