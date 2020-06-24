#decompress it
Expand-Archive C:\installSource\Oracle\winx64_12201_client.zip -DestinationPath C:\installSource\Oracle\installer

#call to a batch file so that -waitforcompletion works
& C:\installSource\Oracle\part2.bat