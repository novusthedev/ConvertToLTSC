# Windows 10 to 10 Enterprise LTSC
This script allows you to install Windows 10 Enterprise LTSC in-place from the regular release.

## We do not encourage piracy in any way. The product keys provided are generic and cannot be used to activate legitimately.

### Only works on Windows 10! Windows 11 is currently not supported.

How-to:
1. Run "Powershell ISE" as admin. (NOT the x86 version!)
2. Open the downloaded `Install OS.ps1` file.
3. Run `Set-ExecutionPolicy Bypass` in the built-in command line. Press A or "Yes to all" to ignore warnings.
4. Mount your downloaded ISO and replace "D:\" in "$InstallDrive" with the mounted drive letter.
5. Press the green run button to start installing. This may take awhile, your system will not reboot after it's complete.
6. Wait for installation to finish and follow on-screen instructions.

We recommend installing any Windows updates, as it might've reverted some updates installed on your previous install.

You can also run the `Edition Switcher.ps1` script if you'd like to change to IoT Enterprise LTSC. (Only on build 19044.2033 or later)