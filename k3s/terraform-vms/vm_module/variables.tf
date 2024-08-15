# vm_module/variables.tf
variable "vm_count" {
  type = number
}

variable "vm_name_prefix" {
  type = string
}

variable "number_hypervisor_nodes" {
  type = number
}

variable "vmid_start" {
  type = number
}

variable "clone_template" {
  type = string
}

variable "cores" {
  type = number
}

variable "memory" {
  type = number
}

variable "disk_size" {
  type = string
}

variable "ip_base" {
  type = string
}

variable "gateway" {
  type = string
}

variable "nameserver" {
  type = string
}

variable "searchdomain" {
  type = string
}

variable "ssh_user" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "target_storage" {
  type = string
  default = "local-lvm"
}