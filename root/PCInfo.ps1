### Create/Delete OUs
### Eric Caverly & Dave Witwicki
### October 19th, 2022

# Get desired computer name from user
Write-Host "Input Computer Name`n" -ForegroundColor Green
$ComputerName = Read-Host -Prompt ">"

# Test to see if the computer exists
$RemoteConnection = Test-Connection $ComputerName -Count 1 -Quiet

if ($RemoteConnection -eq "True") {
    # Get desired hardware information
    $ComputerHW = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $ComputerName | Select-Object Manufacturer, Model | Format-Table -AutoSize
    $ComputerCPU = Get-CimInstance -ClassName Win32_Processor -ComputerName $ComputerName | Select-Object DeviceID, Name | Format-Table -AutoSize
    $ComputerMemTotal = Get-CimInstance -ClassName Win32_PhysicalMemoryArray -ComputerName $ComputerName | Select-Object MemoryDevices, MaxCapacity | Format-Table -AutoSize
    $ComputerMem = Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $ComputerName | Select-Object DeviceLocator, Manufacturer, PartNumber, Capacity, Speed | Format-Table -AutoSize
    $ComputerDisks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $ComputerName | Select-Object DeviceID, VolumeName, Size, FreeSpace | Format-Table -AutoSize
    $ComputerOS = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName | Select-Object Version

    # Figure out what OS the computer is running from the version string
    switch -Wildcard ($ComputerOS) {
        "6.1.7600" {$OS = "Windows 7"; break}
        "6.1.7601" {$OS = "Windows 7 SP1"; break}
        "6.2.9200" {$OS = "Windows 8"; break}
        "6.3.9600" {$OS = "Windows 8.1"; break}
        "10.0.10240" {$OS = "Windows 10 1507"; break}
        "10.0.10586" {$OS = "Windows 10 1511"; break}
        "10.0.14393" {$OS = "Windows 10 1607"; break}
        "10.0.15063" {$OS = "Windows 10 1703"; break}
        "10.0.16299" {$OS = "Windows 10 1709"; break}
        "10.0.17134" {$OS = "Windows 10 1803"; break}
        "10.0.17763" {$OS = "Windows 10 1809"; break}
        "10.0.18362" {$OS = "Windows 10 1903"; break}
        "10.0.18363" {$OS = "Windows 10 1909"; break}
        "10.0.19041" {$OS = "Windows 10 2004"; break}
        "10.0.19042" {$OS = "Windows 10 20H2"; break}
        "10.0.19043" {$OS = "Windows 10 21H1"; break}
        "10.0.19044" {$OS = "Windows 10 21H2"; break}
        "10.0.22000" {$OS = "Windows 11 21H2"; break}
        "10.0.22621" {$OS = "Windows 11 22H2"; break}
        "10.0.20348" {$OS = "Windows Server 2022"; break}
        default {$OS = "Unknown Operating System"; break}
    }

    # Output information
    Write-Host "Computer Name: $ComputerName"
    Write-Host "Operating System: $OS"
    Write-Output $ComputerHW
    Write-Output $ComputerCPU
    Write-Output $ComputerMemTotal
    Write-Output $ComputerMem
    Write-Output $ComputerDisks
}
# If the computer cannot be reached
else {
    Write-Host "Computer Unreachable or Nonexistent" -ForegroundColor Red
}

# show something so the display doesn't immediately clear
Show-Message "Completed" Blue