#only run if:
#   gcdocsDSC.sha256 is missing
#   GCDOCSDsc.sha256 is different

param (
    [switch]$Force,
    [string]$Filename = "$PSScriptRoot\GCDOCSDsc.sha256",
    [string]$DSCFilename = "$PSScriptRoot\dsc.ps1"
)

write-output "Running From $PSScriptRoot"

$DoRun = $False
if ((test-Path GCDOCSDsc.sha256) -eq $false) {
    write-output "No SHA256 file found. Running."
    $DoRun = $True #no SHA256
} else {
    #test md5 to see if it matches
    $OldSHA256 = Get-Content $Filename
    $NewSHA256 = (Get-FileHash $DSCFilename -Algorithm SHA256).Hash

    if ($OldSHA256 -ne $NewSHA256) {
        write-output "SHA256 does not match. Running."
        write-output "Old Hash: $OldSHA256"
        $DoRun = $True #no SHA256
    }
}

if ($DoRun -eq $true -or $Force -eq $true) {
    #load the config
    write-output "Generating new SHA256"
    . $DSCFilename

    if ($? -eq $false) {
        #delete the hash, the file is invalid
        del $Filename -force

        Exit 1 #1 is bad
    } else {
        #run it to compile, need to be true or else fails
        write-output "Compiling Configurations"
        GCDOCSDsc | Out-Null

        #update Hash
        $NewSHA256 = (Get-FileHash $DSCFilename -Algorithm SHA256).Hash
        Set-Content $Filename -Value $NewSHA256

        write-output "New Hash: $NewSHA256"

        Exit 0 #0 is good
    }
} else {
    write-output "No changes or missing files. Skipping"

    Exit 0 #0 is good
}

