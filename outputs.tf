output "admin_ssh_key_public" {
  description = "The generated public key data in PEM format"
  value       = var.generate_admin_ssh_key == true && var.os_flavor == "linux" ? tls_private_key.rsa[0].public_key_openssh : null
}

output "admin_ssh_key_private" {
  description = "The generated private key data in PEM format"
  sensitive   = true
  value       = var.generate_admin_ssh_key == true && var.os_flavor == "linux" ? tls_private_key.rsa[0].private_key_pem : null
}

output "windows_vm_password" {
  description = "Password for the windows VM"
  sensitive   = true
  value       = try(random_password.passwd[0].result, var.admin_password)
}

output "virtual_machine" {
  description = "The Virtual Machine object"
  value       = var.os_flavor == "windows" && var.use_azapi == false ? azurerm_windows_virtual_machine.win_vm[0] : var.os_flavor == "windows" && var.use_azapi == true ? azapi_resource.win_vm[0] : azurerm_linux_virtual_machine.linux_vm[0]
}
