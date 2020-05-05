#load the config
write-output "Importing Configurations"
. .\dsc.ps1

#run it to compile
write-output "Compiling Configurations"
GCDOCSDsc 

#convert output down to UTF8, it does UTF16 for some reason. Terraform hates this
write-output "Converting to UTF-8"
$in = Get-Content GCDOCSDsc\localhost.mof
remove-Item GCDOCSDsc\localhost.mof
Set-Content -Encoding utf8 -Path GCDOCSDsc\localhost.mof -Value $in