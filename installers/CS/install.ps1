#create the log folder
mkdir C:\installLog

#don't know if les pre-install needs to run, but it gives errors
msiexec.exe /qn /i "C:\installSource\CS\les_pre_install.MSI" `
    TRANSFORMS="C:\installSource\CS\les_pre_install.mst" `
    allusers=1 reboot=reallysuppress `
    /l*v C:\installLog\les_pre_install.log `
    LES_PRE_INST_RESULTFILE="C:\installLog\les.ini"

#install CS
msiexec.exe /qn /i "C:\installSource\CS\16.2.11_CS64_Win.MSI" `
    TRANSFORMS="C:\installSource\CS\gcdocs.mst" `
    INSTALLDIR=C:\OPENTEXT\CS162 `
    allusers=1 reboot=reallysuppress `
    /l*v C:\installLog\gcdocs.log