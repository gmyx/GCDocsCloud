/* each cluster can contain one more more VMs */


//right now, will use more traditional methods 
//but in terraform 0.13, it should be possible to be more dynamic

module "VM_Single" {
  source = "./WinVM"

  count = "${var.name == "single" ? 1 : 0}"
}