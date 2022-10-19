configuration BuildAndReleaseAgent {

    Import-DscResource -ModuleName cChoco
    Import-DscResource -ModuleName PowerShellModule
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    node localhost
    {
      
        WindowsFeature EnableGPO {
            Name   = "GPMC"
            Ensure = "Present"
        }

        #region begin region Registry
        Registry DisableWindowsUpdateAUOptions {
            Ensure    = "Present"  
            Key       = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
            ValueName = "AUOptions"
            ValueData = "1"
        }   

        Registry DisableWindowsUpdateAu {
            Ensure    = "Present"  
            Key       = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
            ValueName = "NoAutoUpdate"
            ValueData = "1"
        }  

        Registry DisableIESecurityAdminKey {
            Ensure    = "Present"  
            Key       = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
            ValueName = "IsInstalled"
            ValueData = "0"
        }
        #endregion region Registry

        Service Servicewuauserv {
            Name        = "wuauserv"
            StartupType = "Disabled"
            State       = "Stopped"
        }

        Environment EnvironmentJava {
            Name   = "Java" 
            Value  = "C:\Program Files\Zulu\zulu-11\bin\"
            Path   = $true
            Ensure = "Present"
        }

        #region begin region PSModuleResource
        PSModuleResource installPSScriptAnalyzer1200 {
            Ensure          = 'present'
            Module_Name     = 'PSScriptAnalyzer'
            RequiredVersion = '1.20.0'
        }

        PSModuleResource installAzureAD202137 {
            Ensure          = 'present'
            Module_Name     = 'AzureAD'
            RequiredVersion = '2.0.2.137'
        }
        #endregion PSModuleResource

        #region begin region choco and cChocoInstaller
        cChocoInstaller InstallChoco {
            InstallDir = "c:\choco"
        }
        
        cChocoPackageInstaller installDotNetCore3129 {
            Name      = 'dotnetcore'
            Ensure    = 'Present'
            DependsOn = '[cChocoInstaller]installChoco'
            Version   = '3.1.29'
        } 

        cChocoPackageInstaller installNotepad845 {
            Name      = 'notepadplusplus.install'
            Ensure    = 'Present'
            DependsOn = '[cChocoInstaller]installChoco'
            Version   = '8.4.5'
        }

        cChocoPackageInstaller installAzCLI2400 {
            Name      = 'azure-cli'
            Ensure    = 'Present'
            DependsOn = '[cChocoInstaller]installChoco'
            Version   = '2.40.0'
        }

        cChocoPackageInstaller installPowershellCore726 {
            Name      = 'powershell-core'
            Ensure    = 'Present'
            DependsOn = '[cChocoInstaller]installChoco'
            Version   = '7.2.6'
        }

        cChocoPackageInstaller installNodeJS18110 {
            Name      = 'nodejs.install'
            Ensure    = 'Present'
            DependsOn = '[cChocoInstaller]installChoco'
            Version   = '18.11.0'
        }

        cChocoPackageInstaller installGit2373 {
            Name      = 'git'
            Ensure    = 'Present'
            DependsOn = '[cChocoInstaller]installChoco'
            Version   = '2.37.3'
        }

        cChocoPackageInstaller installVisualstudio2022Community {
            Name      = 'visualstudio2022community'
            Ensure    = 'Present'
            DependsOn = '[cChocoInstaller]installChoco'
            Version   = '117.3.5.0'
        }

        cChocoPackageInstaller installPester533 {
            Name      = 'pester'
            Ensure    = 'Present'
            DependsOn = '[cChocoInstaller]installChoco'
            Version   = '5.3.3'
        }
        #endregion choco and cChocoInstaller
        
        #region begin region Script
        Script ScriptExample {
            SetScript  = {
                $sw = New-Object System.IO.StreamWriter("C:\TempFolder\TestFile.txt")
                $sw.WriteLine("Some sample string")
                $sw.Close()
            }
            TestScript = { Test-Path "C:\TempFolder\TestFile.txt" }
            GetScript  = { @{ Result = (Get-Content C:\TempFolder\TestFile.txt) } }
        }
        #endregion Scriptblock
    }
}
BuildAndReleaseAgent