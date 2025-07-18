#########################################################################################
#  Common parameters                                                                    #
#########################################################################################
variable "location" {
  description = "Defines the Azure location where the resources will be deployed"
  type        = string
  default     = "eastus"
}

variable "resourcegroup_name" {
  description = "If defined, the name of the resource group into which the resources will be deployed"
  default     = "testlab"
}

variable "resourcegroup_tags" {
  description = "tags to be added to the resource group"
  default     = {}
}

variable "is_diagnostic_settings_enabled" {
  description = "Whether diagnostic settings are enabled"
  default     = false
}

variable "diagnostic_target" {
  description = "The destination type of the diagnostic settings"
  default     = "Log_Analytics_Workspace"
  validation {
    condition     = contains(["Log_Analytics_Workspace", "Storage_Account", "Event_Hubs", "Partner_Solutions"], var.diagnostic_target)
    error_message = "Allowed values are Log_Analytics_Workspace, Storage_Account, Event_Hubs, Partner_Solutions"
  }
}

variable "infrastructure" {
  description = "Details of the Azure infrastructure to deploy the SAP landscape into"
  default     = {}
}

variable "disable_telemetry" {
  type        = bool
  description = "If set to true, will disable telemetry for the module. See https://aka.ms/alz-terraform-module-telemetry."
  default     = false
}
variable "lock" {
  type = object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
  default     = {}
  description = <<LOCK
"The lock level to apply to all child resources. The default value is none. Possible values are `None`, `CanNotDelete`, and `ReadOnly`. Set the lock value on child resource values explicitly to override any inherited locks." 

Example Inputs:
```hcl
lock = {
  name = "lock-{resourcename}" # optional
  type = "CanNotDelete" 
}
```
LOCK
  nullable    = false

  validation {
    condition     = contains(["CanNotDelete", "ReadOnly", "None"], var.lock.kind)
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

#########################################################################################
#  Virtual Machine parameters                                                           #
#########################################################################################
variable "ssh_key" {
  description = "ssh_key"
  default     =  "sh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCZ/KXKM5ZVSV3G2+jklYn7xMLZj4SGjtsMTe1a4vcGYuz91B6X6Q3icHt4scqm0mlJiiSkR+C6dXQ+g+BDx/HnsE1s84iSAqqCcs9RCHIGrKCjH6MOeTTB9zvDkgXE61r0Ljml+6LbLeyCX6GRW4CUgj6GQ2vfgc5kXm7Up+EcJJjd+K4dRMHCVEV4Zt4082/UY08p4PzG2jCFDCGMj27IlH+Gvjptz6lxDf5Zdm8OYApWwhHIb4YpHmiFY0z8Tnlp2/PK6d+loOJxZ+Uu+sMX4WwuVk8xRUXMWRCyv72CMY5ZF8uCwWM7DlflM3RYhF9nQLiYi7oaez7i3YXjEtmrsOWBh9LYPWqPfrrznfiI2PAP+ywuSzhiQfobRZMeOwJDaQIDYGScykF+P9TGKxcR7UIZKVlsM154IXgVXVpQgbVwOlh29PUdWHYzN6I6uftYADbV7EJvkbh8gH17kvdI6BZP5lsMO+dJuafvLZl9zj2QzM9WrsFpRRYFQ9EJFraBK0YCMrA4CFtwIptmAXNcnqmsTAtldOF01x6gDrrBfc3e6hFZze9Fb3XY8Q76Xe7OeWb2Mi2ceBuGD2drvUDsOuLoKGbaZZrZuWtAijAzewyyVs3oUCuK/tco3PQ7bBtdPzRFNuCmlUoHqZ/1lZOPYk0t89cofx8sSqGxApzf8Q="
}

variable "vm_sku" {
  description = "The SKU of the virtual machine"
  default     = "Standard_D4s_v3"
}

variable "vm_source_image_reference" {
  description = "The source image reference of the virtual machine"
  default = {
    publisher = "Oracle"
    offer     = "oracle-database-19-3"
    sku       = "oracle-database-19-0904"
    version   = "latest"
  }
}

variable "vm_os_disk" {
  description = "Details of the OS disk"
  default = {
    name                   = "osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_encryption_set_id = null
    disk_size_gb           = 128
  }
}

variable "vm_user_assigned_identity_id" {
  description = "3c95d2c9-661f-4449-83c2-22c4d27d7027"
}

variable "vm_extensions" {
  description = "The extensions to be added to the virtual machine"
  type = map(object({
    name                        = string
    publisher                   = string
    type                        = string
    type_handler_version        = string
    auto_upgrade_minor_version  = optional(bool)
    automatic_upgrade_enabled   = optional(bool)
    failure_suppression_enabled = optional(bool, false)
    settings                    = optional(string)
    protected_settings          = optional(string)
    provision_after_extensions  = optional(list(string), [])
    tags                        = optional(map(any))
    protected_settings_from_key_vault = optional(object({
      secret_url      = string
      source_vault_id = string
    }))
  }))
  default = {}
}
#########################################################################################
#  Database parameters                                                                  #
#########################################################################################
variable "database" {
  description = "Details of the database node"
  default = {
    use_DHCP = true
    authentication = {
      type = "key"
    }
    data_disks = [
      {
        count                     = 1
        caching                   = "ReadOnly"
        create_option             = "Empty"
        disk_size_gb              = 1024
        lun                       = 0
        disk_type                 = "Premium_LRS"
        write_accelerator_enabled = false
      },
      {
        count                     = 1
        caching                   = "None"
        create_option             = "Empty"
        disk_size_gb              = 1024
        lun                       = 1
        disk_type                 = "Premium_LRS"
        write_accelerator_enabled = false
      }
    ]
  }
}

variable "database_disks_options" {
  description = "Details of the database node"
  default = {
    data_disks = [
      {
        count                     = 1
        caching                   = "ReadOnly"
        create_option             = "Empty"
        disk_size_gb              = 1024
        lun                       = 1
        disk_type                 = "Premium_LRS"
        write_accelerator_enabled = false
      }
    ],
    asm_disks = [
      {
        count                     = 1
        caching                   = "ReadOnly"
        create_option             = "Empty"
        disk_size_gb              = 1024
        lun                       = 0
        disk_type                 = "Premium_LRS"
        write_accelerator_enabled = false
      }
    ]
    redo_disks = [
      {
        count                     = 1
        caching                   = "None"
        create_option             = "Empty"
        disk_size_gb              = 1024
        lun                       = 2
        disk_type                 = "Premium_LRS"
        write_accelerator_enabled = false
      }
    ]
  }
}

variable "database_db_nic_ips" {
  description = "If provided, the database tier virtual machines will be configured using the specified IPs"
  default     = [""]
}

variable "jit_wait_for_vm_creation" {
  description = "The duration to wait for the virtual machine to be created before creating the JIT policy"
  default     = "60s"
}
