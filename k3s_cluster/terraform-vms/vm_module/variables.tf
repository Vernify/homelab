# vm_module/variables.tf
variable "vm_count" {
  type = number
}

variable "name_prefix" {
  type = string
}

variable "number_hypervisor_nodes" {
  type = number
}

variable "disk_format" {
  description = "The format of the disk (e.g., raw, qcow2)"
  type        = string
  default     = "qcow2"
}

variable "vmid_base" {
  type = number
}

variable "description" {
  type = string
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

variable "cloudinit_storage" {
  type = string
}

variable "disk_size" {
  type = string
}

variable "disk_storage" {
  type = string
}

variable "ip_base" {
  type = number
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

variable "provisioner_inline" {
  type = list(string)
}