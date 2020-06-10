write-output "Copying AzCopy"
$newToken = $env:SASTOKEN.Replace('?',"/azcopy.exe?")
(New-Object System.Net.WebClient).DownloadFile($newToken,'c:\windows\azcopy.exe')