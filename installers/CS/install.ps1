#create the log folder
mkdir G:\installLog

#don't know if les pre-install needs to run, but it gives errors
msiexec.exe /qn /i "F:\installSource\CS\les_pre_install.MSI" `
    TRANSFORMS="F:\installSource\CS\les_pre_install.mst" `
    allusers=1 reboot=reallysuppress `
    /l*v G:\installLog\les_pre_install.log `
    LES_PRE_INST_RESULTFILE="G:\installLog\les.ini"

#install CS
msiexec.exe /qn /i "F:\installSource\CS\16.2.11_CS64_Win.MSI" `
    TRANSFORMS="F:\installSource\CS\gcdocs.mst" `
    INSTALLDIR=F:\OPENTEXT\CS162 `
    allusers=1 reboot=reallysuppress `
    /l*v G:\installLog\gcdocs.log