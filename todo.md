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
| determine how to import resources | Solutions found, needed to be added to modules | In Progress
| integrate the PSPC tagging guidlines | | Not Started |
| name the components per PSPC naming guidelines | | Not Started |
| in DSc Module, Find a way to mask the client secret. Write it to file? | | Not Started |
| in DSC module, add a privitioner to destroyu the compiled MOF | | Not Started |
| in VM DSC section, add a method to detroy the asssociation (to be verifyed) | | Not Started |
| ImageBuilder: Use shared image gallery | Exploring | In progress |
| ImageBuilder: Import MSI from storage account to deploy CS/Orcale Client | Testing DSC solutions | In Progress |
| Explore the possiblilty of partial DSCs allowing a DRY DSC | | Not Started |
| Determine a method to updated DSC without destroying a VM | DSC updates when the compiled version updates | Done |