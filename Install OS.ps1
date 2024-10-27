# Values
$sys = (Get-WmiObject Win32_OperatingSystem).SystemDrive

# Tips

# Mount your downloaded ISO and set the InstallDrive to the letter mounted.
# Note: Use your own architecture (x64 for x64, arm64 for arm64).
# Enterprise LTSC is installed by default to respect system language as IoT Enterprise ISO's only support English.
# You can use the Edition Switcher script after installing if you want to use IoT Enterprise. Make sure your system is up to date first.
# The product key provided is generic and cannot be used to legitimately activate Windows.

$InstallDrive = "D:\"

# Script
$adminCheck = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
if ($adminCheck.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    
$Build = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild).CurrentBuild
$Edition = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name EditionID).EditionID

clear
Write-Host "Current Build: $Build"
Write-Host "Current Edition: $Edition"

# Windows 11 is NOT supported at the moment.
if ($Build -le 19045) {

# Warn and notify the user on what they're doing.
Write-Host "WARNING: This will break activation. You'll need to manually activate after installing! Failure to activate may cause issues."
Write-Host "NOTE: Some apps, updates, and drivers may need to be updated or re-installed. Some settings may have to be re-configured."
$confirmation = Read-Host "This will install Enterprise LTSC on to your system. Are you sure you want to proceed? (y/n)"
if ($confirmation -eq 'y') {

try {
 
    # Set the edition value to Enterprise LTSC to prevent any errors.
    Set-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name EditionID -Value "EnterpriseS" -Force

    Write-Host "Windows is now installing, this may take awhile. You can proceed to using your PC as normal."

    # Start Windows Setup silently
    Start-Process -Wait -Verb RunAs -FilePath $InstallDrive\setup.exe -ArgumentList "/quiet /noreboot /DynamicUpdate disable /auto upgrade /pkey M7XTQ-FN8P6-TTKYV-9D4CC-J462D"

    Write-Host "Installation complete. You may now save your data & reboot."

    $rebootCom = Read-Host "Do you want to reboot now? (y/n)"
    if ($rebootCom -eq 'y') {
        Start-Process -Wait -Verb RunAs -FilePath shutdown -ArgumentList "-r -t 0"
    }

} catch {
  Write-Host -Foreground Red "An error occurred while installing. Your system has not been affected."
}
}

}else {
Write-Host -Foreground Red "Windows 10 is required! Windows 11 is currently unsupported at the moment."
}

} else {
    Write-Host -Foreground Yellow "Please run as an Administrator."
}