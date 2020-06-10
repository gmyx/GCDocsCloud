#since we know the size of the disks, we can pick and choose how to init
#disk 1 == 80gb -> 80 000 000 000
#disk 2 == 40gb -> 40 000 000 000
write-output "*** Initializing Disks ***"

write-output "Disks: "
get-disk | select Number, PartitionStyle, FriendlyName, Size | out-host

write-output "Partitions: "
Get-Partition | Select PartitionNumber, DriveLetter, Size, type | out-host

write-output "Setup F:"
Get-Disk | Where PartitionStyle -ieq 'raw' | Where Size -gt 80000000000 | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -DriveLetter F -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Application" -Confirm:$false | out-host

write-output "Setup G:"
Get-Disk | Where partitionstyle -ieq 'raw' | Where Size -gt 40000000000 | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -DriveLetter G -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Logs" -Confirm:$false | out-host

write-output "Disks: "
get-disk | select Number, PartitionStyle, FriendlyName, Size | out-host
write-output "Partitions: "
Get-Partition | Select PartitionNumber, DriveLetter, Size, type | out-host
write-output "*** Done initializing disks ***"


#if there is still a raw partition, error out!
$Count = (Get-Disk | where PartitionStyle -eq 'raw' | Measure-Object).count
if ($count -gt 0) {
    Exit 1 #error
}