# This resource only exists to support preview features. It was originally created to support hibernation which must be enabled on VM creation
# See https://github.com/hashicorp/terraform-provider-azurerm/issues/24780 for details

locals {
  vm_parent_id = trimsuffix(azurerm_network_interface.nic.id, "/providers/Microsoft.Network/networkInterfaces/${azurerm_network_interface.nic.name}")
}

resource "azapi_resource" "win_vm" {
  count     = var.os_flavor == "windows" && var.use_azapi == true ? 1 : 0
  type      = "Microsoft.Compute/virtualMachines@2023-03-01"
  parent_id = local.vm_parent_id
  name      = var.virtual_machine_name
  location  = var.location
  identity {
    type = "SystemAssigned"
  }
  body = jsonencode({
    properties = {
      additionalCapabilities = {
        hibernationEnabled = true
      }
      licenseType = var.license_type

      diagnosticsProfile = {
        bootDiagnostics = {
          enabled = false
        }
      }
      hardwareProfile = {
        vmSize = var.virtual_machine_size
      }
      networkProfile = {
        networkInterfaces = [
          {
            id = azurerm_network_interface.nic.id
            properties = {
              primary = true
            }
          },
        ]
      }
      osProfile = {
        adminPassword            = var.admin_password == null ? random_password.passwd[0].result : var.admin_password
        adminUsername            = var.admin_username
        allowExtensionOperations = true
        computerName             = var.host_name

        windowsConfiguration = {
          patchSettings = {
            enableHotpatching      = true
            enableAutomaticUpdates = var.enable_automatic_updates
            patchMode              = var.patch_mode
          }
          provisionVMAgent = var.provision_vm_agent
          timeZone         = var.timezone
        }
      }
      priority = "Regular"
      storageProfile = {
        osDisk = {
          storage_account_type = var.os_disk_storage_account_type
          caching              = "ReadWrite"
          name                 = var.os_disk_name != null ? var.os_disk_name : "${var.virtual_machine_name}-osdisk"
        }
        imageReference = {
          publisher = local.image["publisher"]
          offer     = local.image["offer"]
          sku       = local.image["sku"]
          version   = local.image["version"]
        }
      }
      zones = [var.availability_zone]
    }
  })

  lifecycle {
    ignore_changes = [
      identity
    ]
  }
}
