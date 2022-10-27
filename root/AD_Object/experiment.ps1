$running = $true

while($running) {
    $contents = Get-ADOrganizationalUnit -Properties CanonicalName -Filter * | Select-Object -ExpandProperty CanonicalName
    $contArray = @($contents)
    $contents2 = Get-ADOrganizationalUnit -Properties DistinguishedName -Filter * | Select-Object -ExpandProperty DistinguishedName
    $contArray2 = @($contents2)

    $opt = @()
    for ($i = 0; $i -le $contArray.length; $i++) {
        $item = $contArray[$i-1]
        $opt+=,@("$item", "$i")
    }

    $sel = Build-Menu "Select an OU" "Blah" $opt

    switch ($sel) {
        1 { CreateOU($contArray2[$sel]) }
        2 { DeleteOU }
    }

}