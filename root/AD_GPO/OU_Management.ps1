### Create/Delete Organizational Unit
### Eric Caverly & Dave Witwicki
### October 19th, 2022

# List Organizational Units
function ListOU() {   
}

# Create Organizational Unit
function CreateOU() {
}

# Delete Organizational Unit
function DeleteOU {
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