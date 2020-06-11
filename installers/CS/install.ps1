#create the log folder
mkdir G:\installLog

#don't know if les pre-install needs to run, but it gives errors
msiexec.exe /i "F:\installSource\CS\les_pre_install.MSI" `
    TRANSFORMS="F:\installSource\CS\les_pre_install.mst" `
    allusers=1 reboot=reallysuppress `
    /log F:\installLog\les_pre_install.log `
    LES_PRE_INST_RESULTFILE="G:\installLog\les.ini"

#install CS
msiexec.exe /i "F:\installSource\CS\16.2.11_CS64_Win.MSI" `
    TRANSFORMS="G:\installSource\CS\gcdocs.mst" `
    allusers=1 reboot=reallysuppress `
    /log F:\installLog\gcdocs.log