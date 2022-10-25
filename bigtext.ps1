### Big Text Script
### Eric Caverly
### October 24th, 2022

$Aletter = @("   /\  ",
             "  /--\ ",
             " /    \")

$Bletter = @(" |^^\ ",
             " |---|",
             " |__/ ")

$Cletter = @(" /^^^",
             " |   ",
             " \___")

$Dletter = @(" |^^\ ",
             " |   |",
             " |__/ ")

$Eletter = @(" |^^^",
             " |---",
             " |___")

$Fletter = @(" |^^^",
             " |---",
             " |   ")

$Gletter = @(" |^^^ ",
             " |  -|",
             " |___|")

$Hletter = @(" |   |",
             " |---|",
             " |   |")

$Iletter = @(" ^^|^^",
             "   |  ",
             " __|__")

$Jletter = @(" ^^^|",
             "    |",
             " \__/")

$Kletter = @(" | /",
             " |- ",
             " | \")

$Lletter = @(" |  ",
             " |  ",
             " |__")

$Mletter = @(" |\/|",
             " |  |",
             " |  |")

$Nletter = @(" |\ |",
             " | \|",
             " |  |")

$Oletter = @(" /^^^\",
             " |   |",
             " \___/")

$Pletter = @(" |^^\",
             " |--/",
             " |   ")

$Qletter = @(" /^^\",
             " |  |",
             " \__\")

$Rletter = @(" |^^\",
             " |--/",
             " |  \")

$Sletter = @(" /^^^ ",
             " \--\ ",
             " ___/ ")

$Tletter = @(" ^^|^^",
             "   |  ",
             "   |  ")

$Uletter = @(" |   |",
             " |   |",
             " \___/")

$Vletter = @(" |  |",
             " \  /",
             "  \/ ")

$Wletter = @(" |  |",
             " |  |",
             " |/\|")

$Xletter = @(" \  /",
             "  || ",
             " /  \")

$Yletter = @(" \ /",
             "  | ",
             "  | ")

$Zletter = @("  ^^^",
             "   / ",
             "  /__")

$COLLON = @(" * ",
            "   ",
            " * ")

$SPACE = @("     ",
           "     ",
      	   "     ") 

$0letter = @(" /^\",
             " | |",
             " \_/")

$1letter = @(" /| ",
             "  | ",
             " _|_")

$2letter = @(" /^\",
             "  / ",
             " /__")

$3letter = @(" ^^\",
             "  -|",
             " __/")

$4letter = @(" | |",
             " ^^|",
             "   |")

$5letter = @(" |^^",
             " ^^\",
             " __/")

$6letter = @(" /^^ ",
             " |--\",
             " \__/")

$7letter = @(" ^^|",
             "   |",
             "   |")

$8letter = @(" /^^\",
             " >--<",
             " \__/")

$9letter = @(" /^^\",
             " \__|",
             "    |")



Function Convert-Lorge($inputText) {
	$global:WIP = @("", "", "")
	for($il=0; $il -lt $inputText.length; $il++) {
		switch ($inputText[$il]) {
			"a" { Add-Letter $Aletter }
			"b" { Add-Letter $Bletter }
			"c" { Add-Letter $Cletter }
			"d" { Add-Letter $Dletter }
			"e" { Add-Letter $Eletter }
			"f" { Add-Letter $Fletter }
			"g" { Add-Letter $Gletter }
			"h" { Add-Letter $Hletter }
			"i" { Add-Letter $Iletter }
			"j" { Add-Letter $Jletter }
			"k" { Add-Letter $Kletter }
			"l" { Add-Letter $Lletter }
			"m" { Add-Letter $Mletter }
			"n" { Add-Letter $Nletter }
			"o" { Add-Letter $Oletter }
			"p" { Add-Letter $Pletter }
			"q" { Add-Letter $Qletter }
			"r" { Add-Letter $Rletter }
			"s" { Add-Letter $Sletter }
			"t" { Add-Letter $Tletter }
			"u" { Add-Letter $Uletter }
			"v" { Add-Letter $Vletter }
			"w" { Add-Letter $Wletter }
			"x" { Add-Letter $Xletter }
			"y" { Add-Letter $Yletter }
			"z" { Add-Letter $Zletter }
			"1" { Add-Letter $1letter }
			"2" { Add-Letter $2letter }
			"3" { Add-Letter $3letter }
			"4" { Add-Letter $4letter }
			"5" { Add-Letter $5letter }
			"6" { Add-Letter $6letter }
			"7" { Add-Letter $7letter }
			"8" { Add-Letter $8letter }
			"9" { Add-Letter $9letter }
			"0" { Add-Letter $0letter }
			" " { Add-Letter $SPACE}
			":" { Add-Letter $COLLON }
		}
	}

	return $global:WIP
}  

Function Add-Letter($Letter) {
	for ($kl=0; $kl -lt 3; $kl++) {
		$global:WIP[$kl] += $Letter[$kl]
	}
}
