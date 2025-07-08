# Do not touch
$sys = (Get-WmiObject Win32_OperatingSystem).SystemDrive
$NTMajor = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentMajorVersionNumber).CurrentMajorVersionNumber
$NTMinor = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentMinorVersionNumber).CurrentMinorVersionNumber
$Build = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild).CurrentBuild
$Rev = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name UBR).UBR
$Edition = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name EditionID).EditionID
$FullBuild = "$NTMajor.$NTMinor.$Build.$Rev"

# Tips

# Mount your downloaded ISO and set the InstallDrive to the letter mounted.
# Note: Use your own architecture (x64 for x64, arm64 for arm64).
# By default, Enterprise LTSC is installed by default to respect system language as IoT Enterprise only supports US English.
# However, IoT Enterprise LTSC can be installed by default to bypass system requirements for Windows 11 installations. This only works if your system language is set to English (US).
# You can use the Edition Switcher script after installing if you want to use IoT Enterprise. Make sure your system is up to date first.
# The product key provided is generic and cannot be used to legitimately activate Windows.

# Values
$InstallDrive = "D:\"
$forceIoT = $false

# Script
$adminCheck = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
if ($adminCheck.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    
    Clear-Host

    # Check if the user is running 26100 (W11 24H2) to 10240 (W10 1507)
    if ($Build -le 26100 -and $Build -ge 10240) {

        # Warn and notify the user on what they're doing.
        Write-Host "WARNING: This will break activation. You'll need to manually activate after installing! Failure to activate may cause issues."
        Write-Host "NOTE: Some apps, updates, and drivers may need to be updated or re-installed. Some settings may have to be re-configured."
        $confirmation = Read-Host "This will install Enterprise LTSC on to your system. Are you sure you want to proceed? (y/n)"
        if ($confirmation -eq 'y') {

            try {

                $setupPath = $InstallDrive + "\sources\setuphost.exe"
                if (Test-Path $setupPath) {
        
                    # Check setup version
                    $setupVersion = (Get-Item $setupPath).VersionInfo.ProductVersion
                    Write-Host -ForegroundColor Cyan "Current Build: $FullBuild"
                    Write-Host -ForegroundColor Magenta "Pending Build: $setupVersion"
                    Write-Host -ForegroundColor Cyan "Current Edition: $Edition"

                    if ($forceIoT -eq $true) {
                        # Set the edition value to IoT Enterprise LTSC as user requested.
                        Set-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name EditionID -Value "IoTEnterpriseS" -Force
                        $productKey = "KBN8V-HFGQ4-MGXVD-347P6-PDQGT"
                    }
                    else {
                        # Set the edition value to Enterprise LTSC otherwise.
                        Set-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name EditionID -Value "EnterpriseS" -Force
                        $productKey = "M7XTQ-FN8P6-TTKYV-9D4CC-J462D"
                    }
                    $setupEdition = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name EditionID).EditionID

                    Write-Host -ForegroundColor Magenta "Pending Edition: $setupEdition"
                    Write-Host "Windows is now installing, this may take awhile. You can proceed to using your PC as normal."

                    # Start Windows Setup silently
                    if ($setupVersion -ge 10.0.26100) {
                        $setup = Start-Process -PassThru -Wait -Verb RunAs -FilePath $InstallDrive\setup.exe -ArgumentList "/EULA accept /Compat IgnoreWarning /Quiet /NoReboot /DynamicUpdate disable /Auto Upgrade /pkey $($productKey)"
                    }
                    else {
                        $setup = Start-Process -PassThru -Wait -Verb RunAs -FilePath $InstallDrive\setup.exe -ArgumentList "/Compat IgnoreWarning /quiet /noreboot /DynamicUpdate disable /auto upgrade /pkey $($productKey)"
                    }

                    if ($setup.ExitCode -ne 0) {
                        if ($setup.ExitCode -eq -1047526912) {
                            Write-Host -Foreground Yellow "Your system does not meet the minimum requirements."

                            if ($setupVersion -ge 10.0.26100 -and $forceIoT -eq $false) {
                                Write-Host "It seems like you are trying to install Windows 11 Enterprise LTSC. This edition enforces the standard minimum requirements seen in consumer editions."
                                Write-Host "Here's a brief run-up of the minimum requirements:"

                                # Processor
                                $cpu = (Get-CimInstance Win32_Processor).Name
                                Write-Host "⚙️ $($cpu)"

                                # Storage
                                $drive = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID = '$($sys)'"
                                $sizeGB = $drive.Size / 1GB

                                if ($sizeGB -ge 64) {
                                    Write-Host -Foreground Green "✅ $([math]::Round($sizeGB, 2)) GB of total storage"
                                }
                                else {
                                    Write-Host -Foreground Red "❌ $([math]::Round($sizeGB, 2)) GB of total storage"
                                }

                                # Memory
                                $memoryGB = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
                                if ($memoryGB -ge 4) {
                                    Write-Host -Foreground Green "✅ $([math]::Round($memoryGB, 2)) GB of total memory"
                                }
                                else {
                                    Write-Host -Foreground Red "❌ $([math]::Round($memoryGB, 2)) GB of total memory"
                                }

                                # Secure Boot
                                $secureBoot = $false
                                try {
                                    $null = Confirm-SecureBootUEFI
                                    $secureBoot = $true
                                }
                                catch {
                                    $secureBoot = $false
                                }

                                if ($secureBoot) {
                                    Write-Host -Foreground Green "✅ Secure Boot available"
                                }
                                else {
                                    Write-Host -Foreground Red "❌ Secure Boot unavailable"
                                }

                                # TPM
                                $tpm = Get-WmiObject -Namespace "Root\CIMV2\Security\MicrosoftTpm" -Class Win32_Tpm
                                if ($null -eq $tpm) {
                                    Write-Host -Foreground Red "❌ No TPM/Disabled"
                                }
                                else {
                                    $tpmVersion = $tpm.SpecVersion[0]
                                    switch ($tpmVersion) {
                                        2 { Write-Host -Foreground Green "✅ TPM 2.0" }
                                        1 { Write-Host -Foreground Yellow "⚠️ TPM 1.2" }
                                        default { Write-Host -Foreground Green "⚠️ $tpmVersion (Unknown)" }
                                    }
                                }
                                Write-Host -Foreground Red "Error Code: $($setup.ExitCode)"
                            }

                            Write-Host -ForegroundColor Yellow "Make sure your processor is also supported: https://aka.ms/CPUlist"
                            Write-Host "Please correct these errors when possible. You can additonally force the installation of the the IoT Enterprise edition to bypass these requirements."
                            throw "Minimum requirements not met."
                        }
                        elseif ($setup.ExitCode -eq -1047526908) {
                            Write-Host -Foreground Yellow "It seems like the installation was prevented. These are the most likely reasons why:"
                            Write-Host "* Your current system's language isn't compatible with the edition/image you're trying to install."
                            Write-Host "* You are trying to install an older version of Windows."
                            Write-Host "* The current edition you are installing cannot be found. Try toggling the force IoT option to see if this issue persists. If so, the image you're using likely doesn't support any LTSC editions."
                            Write-Host -Foreground Yellow "Make sure everything is correct before trying again."
                            Write-Host -Foreground Red "Error Code: $($setup.ExitCode)"
                        }
                        elseif ($setup.ExitCode -eq -2147023728 -or $setup.ExitCode -eq 183) {
                            Write-Host -Foreground Yellow "Another instance of the Windows setup is already running."
                            Write-Host -Foreground Red "Error Code: $($setup.ExitCode)"
                        }
                        else {
                            Write-Host -Foreground Red "The instllation has failed. Error Code: $($setup.ExitCode)"
                            throw "Setup failed."
                        }
                    }
                    else {
                        Write-Host -Foreground Green "Installation complete. You may now save your data & reboot."

                        $rebootCom = Read-Host "Do you want to reboot now? (y/n)"
                        if ($rebootCom -eq 'y') {
                            Start-Process -Wait -Verb RunAs -FilePath shutdown -ArgumentList "-r -t 0"
                        }
                    }

                }
                else {
                    Write-Host -Foreground Red "Unable to find Windows setup. Make sure your installation drive is correct then try again."
                    throw "Setup not found."
                }
            }
            catch {
                Write-Host -Foreground Red "An error occurred while installing. Your system has not been affected."
                Set-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name EditionID -Value "$($Edition)" -Force
            }
        }

    }
    else {
        Write-Host -Foreground Red "Your current build is not supported."
    }

}
else {
    Write-Host -Foreground Yellow "Please run as an Administrator."
}