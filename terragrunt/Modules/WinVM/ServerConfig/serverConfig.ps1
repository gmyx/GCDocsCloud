#init the data disks
#adapted from https://devblogs.microsoft.com/scripting/use-powershell-to-initialize-raw-disks-and-to-partition-and-format-volumes/
$Disks = Get-Disk | Where partitionstyle -eq ‘raw’

ForEach ($SingleDisk in $Disks) {
    Initialize-Disk -Number $SingleDisk.Number -PartitionStyle MBR
    $Part = New-Partition -DiskNumber $SingleDisk.Number -AssignDriveLetter -UseMaximumSize
    Format-Volume -Partition $Part -FileSystem NTFS -Confirm:$False
}

#install iis
Configuration WebServerConfiguration
{  
  Node "localhost"
  {        
    WindowsFeature WebServer
    {
      Name = "Web-Server"
      Ensure = "Present"
    }

    WindowsFeature ManagementTools
    {
      Name = "Web-Mgmt-Tools"
      Ensure = "Present"
    }
  }
}

WebServerConfiguration -OutputPath "C:\DscConfiguration"

Start-DscConfiguration -Wait -Verbose -Path "C:\DscConfiguration"

exit 0 #required by azurerm to avoid fails - should probably use last error code