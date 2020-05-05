#install iis
#important note: the name here MUST == terraform name property
Configuration GCDOCSDsc
{  
  Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

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