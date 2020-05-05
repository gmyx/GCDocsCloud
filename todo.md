# Goals
Use scale set to get 2 FEs (prevents use of single NAT?, jump server helps here)
Fixed Admin + Fixed Agent

# Issues
| Issue        | Updates           | Status  |
|--------------|-------------------|---------|
| data disk not yet init | DSC can do it, have script else | Prototyped |
| create a DSC pull server for env type (e.g. dev, pprod, prod) - very low resources needed | No longer needed - Azure Automation account can do it | Replaced |
| temp: RDP in to single | | Done |
| create storage account to host CS installer and Oracle Installer | | Not Started |
| move state files to remote | | Not Started |
| interagrate file with AzureDevOp and pipelines | | Not Started |
| change size of OS disk. don't need 128gb on them. | | Not Started |
| integrate PBMM requirements | | Not Started |
| determine how to import resources | will be needed to move to new tenant | not started
| integrate the PSPC tagging guidlines | | Not Started |
| name the components per PSPC naming guidelines | | Not Started |