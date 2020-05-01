#will be moved later, this is for testing

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

#init the data disks
#adapted from https://devblogs.microsoft.com/scripting/use-powershell-to-initialize-raw-disks-and-to-partition-and-format-volumes/
<#Get-Disk | Where partitionstyle -eq ‘raw’ | `
  Initialize-Disk -PartitionStyle MBR -PassThru | `
  New-Partition -AssignDriveLetter -UseMaximumSize | `
  Format-Volume -FileSystem NTFS -Confirm:$false#>

exit 0 #required by azurerm to avoid fails - should probably use last error code