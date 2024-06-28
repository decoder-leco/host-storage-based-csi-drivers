# locals {
#   vbox_vm_details_template = [
#     // display name, Primary VNIC Public/Private IP for each instance
#     for i in oci_core_instance.ubuntu_vm : <<EOT
#     ${~i.display_name~}
#     Primary-PublicIP: %{if i.public_ip != ""}${i.public_ip~}%{else}N/A%{endif~}
#     Primary-PrivateIP: ${i.private_ip~}
#     EOT
#   ]
# }

locals {
  vbox_vm_details = [
    // display name, Primary VNIC Public/Private IP for each instance
    for vm_display_name in ["vbox_vm"] : <<EOT
    ${~vm_display_name~}
    SSH into the VM:   ssh -i ${var.vm_ssh_auth_desired_keypair.private_key_file} ${var.vm_ssh_auth_desired_keypair.username}@${var.vm_host~}
    EOT
  ]

}