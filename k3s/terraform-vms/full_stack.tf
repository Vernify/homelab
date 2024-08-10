# TODO: Turn VM provisioning into a module for re-use

#module "k3s_masters" {
#  source = "./vernify_vm"
#
#  vm_count             = var.number_k3s_masters
#  vm_name_prefix       = "k3s-master"
#  vm_description_prefix = "K3S Master"
#  target_nodes         = var.number_hypervisor_nodes
#}

#module "k3s_workers" {
#  source = "./proxmox_vm_module"
#
#  vm_count             = var.number_k3s_workers
#  vm_name_prefix       = "k3s-worker"
#  vm_description_prefix = "K3S Worker"
#  target_nodes         = var.hypervisors
#}