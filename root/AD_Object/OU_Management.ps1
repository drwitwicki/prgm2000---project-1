### Create/Delete Organizational Unit
### Eric Caverly & Dave Witwicki
### October 19th, 2022

<#
.SYNOPSIS
Lists all the Organizational Units within the current machine's Active Directory Domain.

.DESCRIPTION
The ListOU function iterates thru each OU object from the root of the Domain and creates a custom object entry containing the friendly and canonical names as well as the number of users and computers contained within each OU. These collected objects are then displayed as a table.

.NOTES
Output is formatted as a table because otherwise the top few rows of the output would get cut off.
#>

function ListOU() {
	Get-ADOrganizationalUnit -Properties CanonicalName -Filter * | Sort-Object CanonicalName | ForEach-Object {
		[pscustomobject]@{
			Name          = Split-Path $_.CanonicalName -Leaf
			CanonicalName = $_.CanonicalName
			UserCount     = @( Get-AdUser -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel ).Count
			ComputerCount = @( Get-AdComputer -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel ).Count
		}
	} | Format-Table -AutoSize Name, CanonicalName, UserCount, ComputerCount
}

# Create Organizational Unit
function CreateOU() {
}

# Delete Organizational Unit
function DeleteOU() {
}

# Main Menu

$opt = @()
$opt+=,@("List OUs", 1)
$opt+=,@("Create OU", 2)
$opt+=,@("Delete OU", 3)

$sel = Build-Menu "Organizational Unit Management" "Select Function" $opt

switch ($sel) {
	1 { ListOU }
	2 { CreateOU }
    3 { DeleteOU }
}

Show-Message "Completed" Blue