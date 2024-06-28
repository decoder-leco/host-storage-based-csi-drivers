/*
*/
output "vbox_vm_summary" {
  description = "Command to SSH into the VBox VM."
  value       = local.vbox_vm_details
}
