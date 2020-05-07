#install iis
#important note: the name here MUST == terraform name property
Configuration GCDOCSDsc
{
  Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
  Import-DscResource -ModuleName 'StorageDSC'

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
    WindowsFeature NET-WCF-HTTP-Activation
    {
      Name = "NET-WCF-HTTP-Activation"
      Ensure = "Present"
    }
    #END REGION: .NET Framework 4.5 Features

    #BEGIN REGION: StorageDSC - Init all 3 Disks
    WaitForDisk Disk2
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
    WaitForDisk Disk4
    {
      DiskId = 4
      RetryIntervalSec = 60
      RetryCount = 60
    }
    Disk EVolume
    {
      DiskId = 2
      DriveLetter = 'E'
      FSLabel = "App"
      DependsOn = '[WaitForDisk]Disk2'
    }
    Disk FVolume
    {
      DiskId = 3
      DriveLetter = 'F'
      FSLabel = "Logs"
      DependsOn = '[WaitForDisk]Disk3'
    }
    Disk GVolume
    {
      DiskId = 4
      DriveLetter = 'G'
      FSLabel = "EFS"
      DependsOn = '[WaitForDisk]Disk4'
    }
    #END REGION: StorageDSC - Init all 3 Disks
  }
}