#decompress it
Expand-Archive F:\installSource\Oracle\winx64_12201_client.zip -DestinationPath F:\installSource\Oracle\installer

#call to a batch file so that -waitforcompletion works
& F:\installSource\Oracle\part2.bat