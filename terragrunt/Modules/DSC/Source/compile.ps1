#only run if:
#   localhost.mof is missing
#   gcdocsDSC.sha256 is missing
#   GCDOCSDsc.sha256 is different

$DoRun = $False
if ((test-Path GCDOCSDsc/localhost.mof) -eq $false) {
    write-output "No MOF file found. Running."
    $DoRun = $True #no mof file
}

if ((test-Path GCDOCSDsc.sha256) -eq $false) {
    write-output "No SHA256 file found. Running."
    $DoRun = $True #no SHA256
} else {
    #test md5 to see if it matches
    $OldSHA256 = Get-Content GCDOCSDsc.sha256
    $NewSHA256 = (Get-FileHash .\dsc.ps1 -Algorithm SHA256).Hash

    if ($OldSHA256 -ne $NewSHA256) {
        write-output "SHA256 does not match. Running."
        $DoRun = $True #no SHA256
    }
}

if ($DoRun -eq $true) {
    #load the config
    write-output "Importing Configurations"
    . .\dsc.ps1

    #run it to compile
    write-output "Compiling Configurations"
    GCDOCSDsc | Out-Null

    #convert output down to UTF8, it does UTF16 for some reason. Terraform hates this
    write-output "Converting to UTF-8"
    $in = Get-Content GCDOCSDsc\localhost.mof
    remove-Item GCDOCSDsc\localhost.mof
    Set-Content -Encoding utf8 -Path GCDOCSDsc\localhost.mof -Value $in

    #update Hash
    $NewSHA256 = (Get-FileHash .\dsc.ps1 -Algorithm SHA256).Hash
    Set-Content GCDOCSDsc.sha256 -Value $NewSHA256
} else {
    write-output "No changes or missing files. Skipping"
}