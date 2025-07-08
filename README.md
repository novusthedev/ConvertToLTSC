# Windows 10/11 Standard to (IoT) Enterprise LTSC
This script allows you to install Windows 10/11 (IoT) Enterprise LTSC in-place from the standard editions. This script also supports LTSB editions seen in Windows 10 versions 1507 & 1607.

## We do not encourage piracy in any way. The product keys provided are generic and cannot be used to activate legitimately.

How-to:
1. Run `Powershell ISE` as admin. (NOT the x86 version!)
2. Open the downloaded `Install OS.ps1` file.
3. Run `Set-ExecutionPolicy Bypass` in the built-in command line. Press `A` or `Yes to all` to ignore warnings.
4. Mount your downloaded ISO and replace `D:\` in `$InstallDrive` with the mounted drive letter.
5. Press the green run button to start installing. This may take awhile, your system will not reboot after it's complete.
6. Wait for installation to finish and follow on-screen instructions.

Optional Step for Windows 11: You can force the installation of IoT Enterprise LTSC by changing the `$forceIoT` to `$true` if you want to bypass Windows 11 standard requirements in the regular Enterprise LTSC edition.

We recommend installing any Windows updates, as it might've reverted some updates installed on your previous install.

You can also run the `Edition Switcher.ps1` script if you'd like to change to IoT Enterprise LTSC. (Only on build 19044.2033 or later)