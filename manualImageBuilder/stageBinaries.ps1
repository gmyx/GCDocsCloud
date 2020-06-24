New-Item -Type Directory -Path f:\installSource
foreach($source in $($env:SOURCEFOLDERS.split(',')))
{
    write-output "Copying $source"
    AzCopy copy "$($env:SASTOKEN.Replace('?',"/$($source)?"))" C:\installSource --recursive
}