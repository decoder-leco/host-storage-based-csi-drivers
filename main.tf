
/***
 * Installation Linux packages and configure Linux Kernel parameters [fs.inotify]
 */
resource "null_resource" "prepare_os" {
  # ---
  # Establishes connection to be used by all
  # generic remote provisioners (i.e. file/remote-exec)
  connection {
    type = "ssh"
    user = var.vm_ssh_auth_desired_keypair.username
    // password = var.root_password
    private_key = file(var.vm_ssh_auth_desired_keypair.private_key_file)
    host        = var.vm_host
  }

  provisioner "file" {
    source      = "./scripts/prepare_os/utils.sh"
    destination = "/tmp/prepare_os.utils.sh"
  }
  provisioner "file" {
    source      = "./scripts/prepare_os/sysctl.fs.inotify.sh"
    destination = "/tmp/prepare_os.sysctl.fs.inotify.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/prepare_os.utils.sh",
      "/tmp/prepare_os.utils.sh",
      "chmod +x /tmp/prepare_os.sysctl.fs.inotify.sh",
      "/tmp/prepare_os.sysctl.fs.inotify.sh"
    ]
  }
  // depends_on = [ ]
}




/***
 * LVM Setup on TopoLVM Dedicated Disk
 * - 
 **/
resource "null_resource" "topolvm_disk_lvm_setup" {
  # ---
  # Establishes connection to be used by all
  # generic remote provisioners (i.e. file/remote-exec)
  connection {
    type = "ssh"
    user = var.vm_ssh_auth_desired_keypair.username
    // password = var.root_password
    private_key = file(var.vm_ssh_auth_desired_keypair.private_key_file)
    host        = var.vm_host
  }

  provisioner "file" {
    source      = "./scripts/k8s/csi/topolvm/disk/lvm/setup.sh"
    destination = "/tmp/topolvm.disk.lvm.setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "rm -f ~/.topolvm.disk.lvm.setup.env.sh || true",
      "echo \"export TOPOLVM_DISK_DEVICE_NAME=${var.topolvm_disk_device_name}\" | tee -a ~/.bashrc | tee -a ~/.topolvm.disk.lvm.setup.env.sh",
      "echo \"export TOPOLVM_VOL_GRP_NAME=${var.topolvm_vol_grp_name}\" | tee -a ~/.bashrc | tee -a ~/.topolvm.disk.lvm.setup.env.sh",
      "chmod +x /tmp/topolvm.disk.lvm.setup.sh",
      "/tmp/topolvm.disk.lvm.setup.sh"
    ]
  }
  depends_on = [
    null_resource.prepare_os
  ]
}














# ---
#  Provision the Docker Registry that 
# will be used by the Kubernetes Cluster
resource "null_resource" "provision_docker_registry" {
  # ...

  # Establishes connection to be used by all
  # generic remote provisioners (i.e. file/remote-exec)
  connection {
    type = "ssh"
    user = var.vm_ssh_auth_desired_keypair.username
    // password = var.root_password
    private_key = file(var.vm_ssh_auth_desired_keypair.private_key_file)
    host        = var.vm_host
  }
  # ---
  #  A dummy minio container is deployed, just to test
  #  that we can access it through the Public IP on 
  #  port 9001 : to test the ingress security rules defined above
  provisioner "file" {
    source      = "./scripts/k8s/docker_registry/provision.sh"
    destination = "/tmp/k8s_docker_registry_provision.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "rm -f ~/.oci_registry_provision.env.sh || true",
      "echo \"export OCI_REGISTRY_CONTAINER_NAME=${var.oci_registry_container_name}\" | tee -a ~/.bashrc | tee -a ~/.oci_registry_provision.env.sh",
      "echo \"export OCI_REGISTRY_PORT=${var.oci_registry_port}\" | tee -a ~/.bashrc | tee -a ~/.oci_registry_provision.env.sh",
      "chmod +x /tmp/k8s_docker_registry_provision.sh",
      "/tmp/k8s_docker_registry_provision.sh"
    ]
  }
  depends_on = [
    null_resource.prepare_os,
    null_resource.topolvm_disk_lvm_setup
  ]
}


# ---
#  Kubernetes Cluster Provisioning
resource "null_resource" "provision_k8s_cluster" {
  # ...

  # Establishes connection to be used by all
  # generic remote provisioners (i.e. file/remote-exec)
  connection {
    type = "ssh"
    user = var.vm_ssh_auth_desired_keypair.username
    // password = var.root_password
    private_key = file(var.vm_ssh_auth_desired_keypair.private_key_file)
    host        = var.vm_host
  }
  # ---
  #  A dummy minio container is deployed, just to test
  #  that we can access it through the Public IP on 
  #  port 9001 : to test the ingress security rules defined above
  provisioner "file" {
    source      = "./scripts/k8s/cluster/provision.sh"
    destination = "/tmp/k8s_cluster_provision.sh"
  }
  provisioner "file" {
    source      = "./scripts/k8s/cluster/cluster.yaml"
    destination = "/tmp/kind_cluster_config.yaml"
  }
  provisioner "remote-exec" {
    inline = [
      "rm -f ~/.k8s_cluster_provision.env.sh || true",
      "echo \"export OCI_REGISTRY_CONTAINER_NAME=${var.oci_registry_container_name}\" | tee -a ~/.bashrc | tee -a ~/.k8s_cluster_provision.env.sh",
      "echo \"export OCI_REGISTRY_PORT=${var.oci_registry_port}\" | tee -a ~/.bashrc | tee -a ~/.k8s_cluster_provision.env.sh",
      "echo \"export KND_CLUSTER_NAME=${var.knd_cluster_name}\" | tee -a ~/.bashrc | tee -a ~/.k8s_cluster_provision.env.sh",
      "echo \"export KND_CLUSTER_CONFIG_FILE=/tmp/kind_cluster_config.yaml\" | tee -a ~/.bashrc | tee -a ~/.k8s_cluster_provision.env.sh",
      "chmod +x /tmp/k8s_cluster_provision.sh",
      "/tmp/k8s_cluster_provision.sh"
    ]
  }
  depends_on = [
    null_resource.prepare_os,
    null_resource.provision_docker_registry,
    null_resource.topolvm_disk_lvm_setup
  ]
}

/***
 * TopoLVM Csi Driver Provisioning
 * - 
 **/
resource "null_resource" "topolvm_csi_provisioning" {
  # ---
  # Establishes connection to be used by all
  # generic remote provisioners (i.e. file/remote-exec)
  connection {
    type = "ssh"
    user = var.vm_ssh_auth_desired_keypair.username
    // password = var.root_password
    private_key = file(var.vm_ssh_auth_desired_keypair.private_key_file)
    host        = var.vm_host
  }

  provisioner "file" {
    source      = "./scripts/k8s/csi/topolvm/provision.sh"
    destination = "/tmp/provision.topolvm.csi.sh"
  }
  provisioner "file" {
    source      = "./scripts/prepare_os/install_golang.sh"
    destination = "/tmp/install.golang.topolvm.csi.sh"
  }
  
  provisioner "remote-exec" {
    inline = [
      "rm -f ~/.topolvm_provisioning.env.sh || true",
      "echo \"export TOPOLVM_CSI_GOLANG_VERSION=${var.topolvm_csi_golang_version}\" | tee -a ~/.bashrc | tee -a ~/.topolvm_provisioning.env.sh",
      "chmod +x /tmp/install.golang.topolvm.csi.sh",
      "/tmp/install.golang.topolvm.csi.sh",
      "echo \"export TOPOLVM_K8S_NS=${var.topolvm_k8s_namespace}\" | tee -a ~/.bashrc | tee -a ~/.topolvm_provisioning.env.sh",
      "echo \"export TOPOLVM_VOL_GRP_NAME=${var.topolvm_vol_grp_name}\" | tee -a ~/.bashrc | tee -a ~/.topolvm_provisioning.env.sh",
      "chmod +x /tmp/provision.topolvm.csi.sh",
      "/tmp/provision.topolvm.csi.sh"
    ]
  }
  depends_on = [
    null_resource.topolvm_disk_lvm_setup,
    null_resource.provision_k8s_cluster
  ]
}