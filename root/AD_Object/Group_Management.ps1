### Create/Delete Active Directory Groups
### Eric Caverly & Dave Witwicki
### October 19th, 2022

# List Groups
function ListADGroup() {   
}

# Create Groups
function CreateADGroup() {
}

# Delete Groups
function DeleteADGroup {
}

# Main Menu

$opt = @()
$opt+=,@("List AD Groups", 1)
$opt+=,@("Create Group", 2)
$opt+=,@("Delete Group", 3)

$sel = Build-Menu "Active Directory Group Management" "Select Function" $opt

switch ($sel) {
	1 { ListADGroup }
	2 { CreateADGroup }
    3 { DeleteADGroup }
}