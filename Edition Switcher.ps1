# Variable setup

$Build = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild).CurrentBuild
$Rev = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name UBR).UBR
$Edition = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name EditionID).EditionID
$BuildRev = "$Build.$Rev"

# Product Keys
# These are generic keys given by Microsoft They can't be used to activate legitimately. If you have your own, please put them here.

$Key = "M7XTQ-FN8P6-TTKYV-9D4CC-J462D"
$IoTKey = "KBN8V-HFGQ4-MGXVD-347P6-PDQGT"

# Script

Clear-Host

Write-Host "Current build & revision: $BuildRev"
Write-Host "Current Edition: $Edition"

# Admin & Build Checks

$adminCheck = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
if ($adminCheck.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
   
   if ($Build -lt 19044) {
   Write-Host -Foreground Red "You're running an older version of Windows that doesn't allow this feature. Please update to 21H2 or later."
}
elseif ($BuildRev -le 19044.2033) {
   Write-Host -Foreground Yellow "Your install is out of date! Please update your system then try again."
}
else {

    $EditionSelect = Read-Host "Select the edition you want to use:
    1. Enterprise LTSC (5 years)
    2. IoT Enterprise LTSC (10 years)
    "
    if ($EditionSelect -eq '1') {
        Start-Process -Wait -Verb RunAs -FilePath changepk -ArgumentList "/ProductKey $Key"
        Write-Host "Edition changed. A reboot is recommended."
    }
    elseif ($EditionSelect -eq '2') {
        Start-Process -Wait -Verb RunAs -FilePath changepk -ArgumentList "/ProductKey $IoTKey"
        Write-Host "Edition changed. A reboot is recommended."
    }
    else {
        Write-Host -Foreground Yellow "Not a valid option. Nothing was changed."
    }

}
} else {
    Write-Host -Foreground Yellow "Please run as an Administrator."
}