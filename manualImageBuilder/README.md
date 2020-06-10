# Packer

This repository contains Packer templates for GCShare server builds

## Prerequisites

### Azure
Az.Storage powershell module

### Non Azure
Copy [AzCopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10) to this folder to update

Copy [Packer](https://releases.hashicorp.com/packer/1.5.1/packer_1.5.1_windows_amd64.zip) to a location on your system PATH

Copy the [Packer Windows Update Provisioner](https://github.com/rgl/packer-provisioner-windows-update/releases/download/v0.9.0/packer-provisioner-windows-update-windows.zip) to the same folder where you copied the Packer executable
