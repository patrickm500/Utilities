<#
Better run as admin because some shit can not be queried without (e.g. BitLocker status)
Green = good
Red = Not good
Purple = possibly not good
#>

$elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
function Client-Checker{
    
    Write-host "" 
    Write-host "#######################################################"
    Write-Host "#               Client Security Checker               #"
    Write-Host "#                   by @LuemmelSec                    #"
    Write-Host "# Will check some basic security settings on a client #"
    Write-host "#######################################################"
    Write-host "" 

    if($elevated -eq $true){
        Write-Host "Local Admin: " -ForegroundColor white -NoNewline; Write-Host $elevated -ForegroundColor Green 
        Write-Host "We have superpowers. All checks should go okay."        
    }
    else{
        Write-Host "Local Admin: " -ForegroundColor white -NoNewline; Write-Host $elevated -ForegroundColor Red
        Write-Host "You don't have super powers. Some checks might fail!"        
    }

    # Run As PPL cheks
    Write-host "" 
    Write-host "#####################################"
    Write-host "# Now checking LSA Protection stuff #"
    Write-host "#####################################"
    Write-host "References: https://itm4n.github.io/lsass-runasppl/" -ForegroundColor DarkGray
    Write-host ""
    try {
        $value = Get-ItemPropertyvalue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -ErrorAction Stop
        
        if ($value -eq 1) {
            Write-Host "RunAsPPL: Enabled" -ForegroundColor Green
        }
        elseif ($value -eq 0) {
            Write-Host "RunAsPPL: Disabled" -ForegroundColor Red
        }
        else {
            Write-Host "RunAsPPL: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
        }
    }
    catch {
        Write-Host "RunAsPPL: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
    }

    # Device Guard checks
    Write-host ""
    Write-host "###################################"
    Write-host "# Now checking Device Guard stuff #"
    Write-host "###################################"
    Write-host "References: https://techcommunity.microsoft.com/t5/iis-support-blog/windows-10-device-guard-and-credential-guard-demystified/ba-p/376419" -ForegroundColor DarkGray
    Write-host "References: https://learn.microsoft.com/en-us/windows/security/threat-protection/device-guard/introduction-to-device-guard-virtualization-based-security-and-windows-defender-application-control" -ForegroundColor DarkGray
    Write-host ""
    $computerInfo = Get-ComputerInfo
    $DeviceGuardStatus = $computerInfo.DeviceGuardSmartStatus

    if ($DeviceGuardStatus -eq "Running") {
        Write-Host "Device Guard is enabled." -ForegroundColor Green
    } else {
        Write-Host "Device Guard is not enabled." -ForegroundColor Red
    }

    # Credential Guard checks
    Write-host ""
    Write-host "###################################"
    Write-host "# Now checking Credential Guard stuff #"
    Write-host "###################################"
    Write-host "References: https://learn.microsoft.com/en-us/windows/security/identity-protection/credential-guard/credential-guard-manage" -ForegroundColor DarkGray
    Write-host ""
    $credentialGuardEnabled = (Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard).SecurityServicesRunning

    if ($credentialGuardEnabled -eq 1) {
        Write-Host "Credential Guard is enabled." -ForegroundColor Green
    } else {
        Write-Host "Credential Guard  is not enabled." -ForegroundColor red
    }

    # AppLocker checks
    Write-host ""
    Write-host "#################################"
    Write-host "# Now checking AppLocker stuff #"
    Write-host "################################"
    Write-host "References: https://learn.microsoft.com/de-de/windows/security/threat-protection/windows-defender-application-control/applocker/applocker-overview" -ForegroundColor DarkGray
    Write-host ""
    $appLockerService = Get-Service -Name AppIDSvc
    if ($appLockerService.Status -eq "Running") {
        Write-Host "AppLocker is running." -ForegroundColor Green
    } else {
        Write-Host "AppLocker is not running." -ForegroundColor Red
    }


    # DMA protection related stuff
    Write-host ""
    Write-host "#####################################"
    Write-host "# Now checking DMA Protection stuff #"
    Write-host "#####################################"
    Write-host "References: https://www.synacktiv.com/en/publications/practical-dma-attack-on-windows-10.html" -ForegroundColor DarkGray
    Write-host "References: https://www.scip.ch/?labs.20211209" -ForegroundColor DarkGray
    Write-host ""
    try {
        $value = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceLock" -Name "AllowDirectMemoryAccess" -ErrorAction Stop
        
        if ($value -eq 1) {
            Write-Host "AllowDirectMemoryAccess: Enabled" -ForegroundColor Red
        }
        elseif ($value -eq 0) {
            Write-Host "AllowDirectMemoryAccess: Disabled" -ForegroundColor Green
        }
        else {
            Write-Host "AllowDirectMemoryAccess: Error (probably regkey doesn't exist - hence enabled)" -ForegroundColor Magenta
        }
    }
    catch {
        Write-Host "AllowDirectMemoryAccess: Error (probably regkey doesn't exist - hence enabled)" -ForegroundColor Magenta
    }
    
    try {
        $value = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -ErrorAction Stop
        
        if ($value -eq 1) {
            Write-Host "EnableVirtualizationBasedSecurity: Enabled" -ForegroundColor Green
        }
        elseif ($value -eq 0) {
            Write-Host "EnableVirtualizationBasedSecurity: Disabled" -ForegroundColor Red
        }
        else {
            Write-Host "EnableVirtualizationBasedSecurity: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
        }
    }
    catch {
        Write-Host "EnableVirtualizationBasedSecurity: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
    }

    try {
        $value = Get-ItemPropertyValue -Path Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -ErrorAction Stop
        
        if ($value -eq 1) {
            Write-Host "HypervisorEnforcedCodeIntegrity: Enabled" -ForegroundColor Green
        }
        elseif ($value -eq 0) {
            Write-Host "HypervisorEnforcedCodeIntegrity: Disabled" -ForegroundColor Red
        }
        else {
            Write-Host "HypervisorEnforcedCodeIntegrity: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
        }
    }
    catch {
        Write-Host "HypervisorEnforcedCodeIntegrity: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
    }

    try {
        $value = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "LockConfiguration" -ErrorAction Stop
        
        if ($value -eq 1) {
            Write-Host "HypervisorEnforcedCodeIntegrity Config Locked: Enabled" -ForegroundColor Green
        }
        elseif ($value -eq 0) {
            Write-Host "HypervisorEnforcedCodeIntegrity Config Locked: Disabled" -ForegroundColor Red
        }
        else {
            Write-Host "HypervisorEnforcedCodeIntegrity Config Locked: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
        }
    }
    catch {
        Write-Host "HypervisorEnforcedCodeIntegrity Config Locked: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
    }

    # BitLocker status 
    Write-host ""
    Write-host "###################################"
    Write-host "# Now checking BitLocker settings #"
    Write-host "# If TPM only > possibly insecure #"
    Write-host "###################################"
    Write-host "References: https://learn.microsoft.com/en-us/powershell/module/bitlocker/add-bitlockerkeyprotector?view=windowsserver2022-ps" -ForegroundColor DarkGray
    Write-host "References: https://luemmelsec.github.io/Go-away-BitLocker-you-are-drunk/" -ForegroundColor DarkGray
    Write-host ""
    $volumes = Get-BitLockerVolume
    foreach ($volume in $volumes) {
        $volumeLabel = $volume.MountPoint
        $bitLockerStatus = $volume.ProtectionStatus
        $keyProtectorType = $volume.KeyProtector.KeyProtectorType

        if ($bitLockerStatus -eq "On") {
            Write-Host "BitLocker on volume $volumeLabel - enabled" -ForegroundColor Green

            if ($keyProtectorType -like "*ExternalKey*") {
                Write-Host "Protection of key material on volume $volumeLabel - possibly insecure" -ForegroundColor Magenta
            }
            elseif ($keyProtectorType -like "*key*" -or $keyProtectorType -like "*pin*") {
                Write-Host "Protection of key material on volume $volumeLabel - okay" -ForegroundColor Green
            }
            else {
                Write-Host "Protection of key material on volume $volumeLabel - possibly insecure" -ForegroundColor Magenta
            }
        }
        else {
            Write-Host "BitLocker on volume $volumeLabel - disabled" -ForegroundColor Red
        }
    }


    # Secure Boot enabled?
    Write-host ""
    Write-host "#####################################"
    Write-host "# Now checking Secure Boot settings #"
    Write-host "#####################################"
    Write-host "References: https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/oem-secure-boot" -ForegroundColor DarkGray
    Write-host ""
    $firmwareType = Get-CimInstance -Namespace root\cimv2\Security\MicrosoftTpm -ClassName Win32_Tpm | Select-Object -ExpandProperty SpecVersion
    if ($firmwareType -ne $null) {
        Write-Host "Secure Boot is enabled." -ForegroundColor Green
    } else {
        Write-Host "Secure Boot is not enabled." -ForegroundColor Red
    }

    # Can the Users group write to SYSTEM PATH folders > Hijacking possibilities?
    Write-host ""
    Write-host "##########################################################"
    Write-host "# Now checking ACLs on folders from PATH System variable #"
    Write-host "##########################################################"
    Write-host "References: " -ForegroundColor DarkGray
    Write-host ""
    $env:Path -split ';' | ForEach-Object {
        $folder = $_
    
        if (Test-Path -Path $folder) {
            $acl = Get-Acl -Path $folder
            $usersGroup = New-Object System.Security.Principal.NTAccount("BUILTIN", "Users")
            $usersAccess = $acl.Access | Where-Object { $_.IdentityReference -eq $usersGroup -and $_.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::Write }
    
            if ($usersAccess -ne $null) {
                Write-Host "Members of the Users Group can write to folder: $folder" -ForegroundColor Red
            } else {
                Write-Host "Members of the Users Group cannot write to folder: $folder" - -ForegroundColor Green
            }
        } else {
            Write-Host "Folder does not exist: $folder"
        }
    }
    
    # Check if WSUS is fetching updates over HTTP instaed of HTTPS?
    Write-host ""
    Write-host "##############################"
    Write-host "# Now checking WSUS settings #"
    Write-host "##############################"
    Write-host "References: " -ForegroundColor DarkGray
    Write-host "https://www.gosecure.net/blog/2020/09/03/wsus-attacks-part-1-introducing-pywsus/"
    try {
        $wsusPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    
        if (Test-Path -Path $wsusPath) {
            $wsusConfiguration = Get-ItemProperty -Path $wsusPath -Name "WUServer"
            $wsusServerUrl = $wsusConfiguration.WUServer
    
            if ($wsusServerUrl -match "^http://") {
                Write-Host "WSUS updates are fetched over HTTP." -ForegroundColor Red
            } else {
                Write-Host "WSUS updates are not fetched over HTTP." -ForegroundColor Green
            }
        } else {
            Write-Host "WSUS is not configured." -ForegroundColor Green
        }
    } catch {
        Write-Host "An error occurred while checking the WSUS configuration."
    }
    
    # PowerShell related checks
    Write-host ""
    Write-host "####################################"
    Write-host "# Now checking PowerShell settings #"
    Write-host "####################################"
    Write-host "References: " -ForegroundColor DarkGray
    Write-host "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.3"
    Write-host ""
    # Check if PowerShell v2 can be run
    $psVersion2Enabled = $false

    $psInfo = New-Object System.Diagnostics.ProcessStartInfo
    $psInfo.FileName = 'powershell.exe'
    $psInfo.Arguments = '-Version 2 -NoExit -Command "exit"'
    $psInfo.RedirectStandardOutput = $true
    $psInfo.RedirectStandardError = $true
    $psInfo.UseShellExecute = $false
    $psInfo.CreateNoWindow = $true

    $psProcess = New-Object System.Diagnostics.Process
    $psProcess.StartInfo = $psInfo

    try {
        [void]$psProcess.Start()
        [void]$psProcess.WaitForExit()

        if ($psProcess.ExitCode -eq 0) {
            $psVersion2Enabled = $true
        }
    } finally {
        [void]$psProcess.Dispose()
    }

    if ($psVersion2Enabled) {
        Write-Host "PowerShell v2 can be run." -ForegroundColor Red
    } else {
        Write-Host "PowerShell v2 cannot be run." -ForegroundColor Green
    }

    # Check the execution policy
    # Check the execution policy
    $executionPolicy = Get-ExecutionPolicy
    if ($executionPolicy -eq "Restricted") {
        Write-Host "Execution Policy is $executionPolicy." -ForegroundColor Green
    } elseif ($executionPolicy -eq "Unrestricted" -or $executionPolicy -eq "Bypass") {
        Write-Host "Execution Policy is $executionPolicy." -ForegroundColor Red
    } else {
        Write-Host "Execution Policy is $executionPolicy." -ForegroundColor Magenta
    }

    # Check the language mode
    $languageMode = $ExecutionContext.SessionState.LanguageMode
    if ($languageMode -eq "FullLanguage") {
        Write-Host "Language Mode is "$languageMode -ForegroundColor Red
    } else {
        Write-Host "Language Mode is "$languageMode -ForegroundColor Green
    }

    # IPv6 settings
    Write-host ""
    Write-host "###############################"
    Write-host "# Now checking PIPv6 settings #"
    Write-host "###############################"
    Write-host "References: https://blog.fox-it.com/2018/01/11/mitm6-compromising-ipv4-networks-via-ipv6/" -ForegroundColor DarkGray
    Write-host "References: https://www.blackhillsinfosec.com/mitm6-strikes-again-the-dark-side-of-ipv6/" -ForegroundColor DarkGray
    Write-host ""
    
    $adapterStatus = Get-NetAdapterBinding | Where-Object {$_.ComponentID -eq "ms_tcpip6"} | Select-Object -Property Name, Enabled
    $adapterStatus | ForEach-Object {
        $adapterName = $_.Name
        if (-not $_.Enabled) {
            Write-Host "IPv6 is disabled on Adapter $adapterName." -ForegroundColor Green
        } else {
            Write-Host "IPv6 is enabled on Adapter $adapterName." -ForegroundColor Red
        }
    }



    Write-host ""
    Write-host "########################################################" -ForegroundColor DarkCyan
    Write-host "# Thats it, all checks done. Off to the report baby ^^ #" -ForegroundColor DarkCyan
    Write-host "########################################################" -ForegroundColor DarkCyan
    Write-host ""
}
