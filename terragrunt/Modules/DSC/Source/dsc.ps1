#install iis
#important note: the name here MUST == terraform name property
Configuration GCDOCSDsc
{
  param(
    #[Parameter(Mandatory=$true)]
    #[ValidateNotNullorEmpty()]
    [string]
    $NetworkShareCredentialName = "blank",

    [string]
    $Environment,

    [string]
    $NetworkSharePath,

    [string]
    $StorageAccountName
  )

  Import-DscResource -ModuleName PSDesiredStateConfiguration
  Import-DscResource -ModuleName StorageDSC
  Import-DscResource -ModuleName ComputerManagementDsc
  $NetworkShareCredential = Get-AutomationPSCredential $NetworkShareCredentialName

  Node "localhost"
  {
    #WindowsFeatures were taken from Borden to match. May not need them all.
    #Note: WebDav is intentionaly omitted

    #BEGIN REGION: File and Storage Services
    #Sub feature File And Storage Services -> File and iSCSI Services -> File Server
    WindowsFeature FS-FileServer
    {
      Name = "FS-FileServer"
      Ensure = "Present"
    }
    #END REGION: File and Storage Services

    #BEGIN REGION: Web Server (IIS)
    WindowsFeature WebServer
    {
      Name = "Web-Server"
      Ensure = "Present"
    }

    #Web Server (IIS) -> Web Server -> Common HTTP Features -> Directory Browsing REMOVE
    WindowsFeature Web-Dir-Browsing
    {
      Name = "Web-Dir-Browsing"
      Ensure = "Absent"
    }

    #Web Server (IIS) -> Web Server -> Request Monitor
    WindowsFeature Web-Request-Monitor
    {
      Name = "Web-Request-Monitor"
      Ensure = "Present"
    }

    #Web Server (IIS) -> Web Server -> Application Development
    WindowsFeature Web-App-Dev
    {
      Name = "Web-App-Dev"
      Ensure = "Present"
    }

    #Web Server (IIS) -> Web Server -> Application Development -> .NET Extensibility 3.5
    WindowsFeature Web-Net-Ext
    {
      Name = "Web-Net-Ext"
      Ensure = "Present"
    }

    #Web Server (IIS) -> Web Server -> Application Development -> .NET Extensibility 4.5
    WindowsFeature Web-Net-Ext45
    {
      Name = "Web-Net-Ext45"
      Ensure = "Present"
    }

    #Web Server (IIS) -> Web Server -> Application Development -> ASP.NET 4.5
    WindowsFeature Web-Asp-Net45
    {
      Name = "Web-Asp-Net45"
      Ensure = "Present"
    }

    #Web Server (IIS) -> Web Server -> Application Development -> CGI
    WindowsFeature Web-CGI
    {
      Name = "Web-CGI"
      Ensure = "Present"
    }

    #Web Server (IIS) -> Web Server -> Application Development -> ISAPI Extensions
    WindowsFeature Web-ISAPI-Ext
    {
      Name = "Web-ISAPI-Ext"
      Ensure = "Present"
    }

    #Web Server (IIS) -> Web Server -> Application Development -> ISAPI Filters
    WindowsFeature Web-ISAPI-Filter
    {
      Name = "Web-ISAPI-Filter"
      Ensure = "Present"
    }

    #Web Server (IIS) -> Management Tools
    WindowsFeature ManagementTools
    {
      Name = "Web-Mgmt-Tools"
      Ensure = "Present"
    }
    #END REGION: Web Server (IIS)

    #BEGIN REGION: .NET Framework 3.5 Features
    #.NET Framework 3.5 Features
    WindowsFeature NET-Framework-Features
    {
      Name = "NET-Framework-Features"
      Ensure = "Present"
    }

    #.NET Framework 3.5 Features -> .NET Framework 3.5 (includes .NET 2.0 and 3.0)
    WindowsFeature NET-Framework-Core
    {
      Name = "NET-Framework-Core"
      Ensure = "Present"
    }

    #.NET Framework 3.5 Features -> HTTP Activation
    WindowsFeature NET-HTTP-Activation
    {
      Name = "NET-HTTP-Activation"
      Ensure = "Present"
    }

    #.NET Framework 3.5 Features -> Non-HTTP Activation
    WindowsFeature NET-Non-HTTP-Activ
    {
      Name = "NET-Non-HTTP-Activ"
      Ensure = "Present"
    }
    #END REGION: .NET Framework 3.5 Features

    #BEGIN REGION: .NET Framework 4.5 Features
    #.NET Framework 3.5 Features -> ASP.NET 4.5
    WindowsFeature NET-Framework-45-ASPNET
    {
      Name = "NET-Framework-45-ASPNET"
      Ensure = "Present"
    }

    #.NET Framework 3.5 Features -> HTTP Activation
    WindowsFeature NET-WCF-HTTP-Activation45
    {
      Name = "NET-WCF-HTTP-Activation45"
      Ensure = "Present"
    }
    #END REGION: .NET Framework 4.5 Features

    #BEGIN REGION: StorageDSC - Init all 3 Disks
    <#WaitForDisk Disk2
    {
      DiskId = 2
      RetryIntervalSec = 60
      RetryCount = 60
    }
    WaitForDisk Disk3
    {
      DiskId = 3
      RetryIntervalSec = 60
      RetryCount = 60
    }
    Disk FVolume
    {
      DiskId = 2
      DriveLetter = 'F'
      FSLabel = "App"
      DependsOn = '[WaitForDisk]Disk2'
    }
    Disk GVolume#>
    #END REGION: StorageDSC - Init all 3 Disks

    #REGION PowerShellExecutionPolicy - enforce RemoteSigned
    PowerShellExecutionPolicy ExecutionPolicy
    {
        ExecutionPolicyScope = "LocalMachine"
        ExecutionPolicy = "RemoteSigned"
    }

    #Test REGION
    File TestFile {
      DestinationPath = "F:\README.TXT"
      Contents = "Application static files $Environment"
      Type = "File"
      Ensure = "Present"
      DependsOn = '[Disk]FVolume'
    }

    File TestFile2 {
      DestinationPath = "G:\README.TXT"
      Contents = "Application Log files ONLY PLEASE!!! `r`n\\$NetworkSharePath\$StorageAccountName\16.2.11_CS64_WIN.exe"
      Type = "File"
      Ensure = "Present"
      DependsOn = '[Disk]GVolume'
    }

    #try to copy the files from the installer share
    <#File CSInstaller {
      #16.2.11_CS64_WIN.exe
      DestinationPath = "F:\Installers\16.2.11_CS64_WIN.exe"
      SourcePath = "\\$NetworkSharePath\$StorageAccountName\16.2.11_CS64_WIN.exe"
      Type = "File"
      Ensure = "Present"
      DependsOn = '[Disk]FVolume'
      Credential = $NetworkShareCredential
    }

    #
    File OracleInstaller {
      #16.2.11_CS64_WIN.exe
      DestinationPath = "F:\Installers\OracleAutomated"
      SourcePath = "\\$NetworkSharePath\$StorageAccountName\OracleAutomated"
      Type = "Directory"
      Recurse = $true
      Ensure = "Present"
      DependsOn = '[Disk]FVolume'
      Credential = $NetworkShareCredential
    }#>
  }
}