# ---
# 
# -
#  mkdir -p ~/.ssh.csi.bench/ && ssh-keygen -t rsa -f ~/.ssh.csi.bench/id_rsa -C 'vagrant@debian_vbox_vm' -b 4096 -N '' -P ''
variable "vm_ssh_auth_desired_keypair" {
  description = "The path to the private and public keys your generated for ssh into your VM."
  default = {
    username : "vagrant" # must be exactly equal to the string provided to the [-C] option of the ssh-keygen command to generate SSH RSA KEY PAIR
    public_key_file : "~/.ssh.csi.bench/id_rsa.pub"
    private_key_file : "~/.ssh.csi.bench/id_rsa"
  }
}

variable "vm_host" {
  type        = string
  description = "the host FQDN or IP address to the Virtualbox VM"
  default     = ""
}



# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > CONTAINER REGISTRY
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# 

variable "oci_registry_container_name" {
  type        = string
  description = "(required) describe your variable"
  default     = "k8s-cluster-registry"
}
variable "oci_registry_port" {
  type        = string
  description = "(required) describe your variable"
  default     = "5001"
}



# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > KIND KUBERNETES CLUSER
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# 
variable "knd_cluster_name" {
  type        = string
  description = "(required) describe your variable"
  default     = "k8s-cluster-decoderleco"
}
variable "knd_net_name" {
  type        = string
  description = "The name of the docker network in which the kind cluster nodes are connected together."
  default     = "kind"
}

# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > METALLB 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# 


variable "metallb_k8s_namespace" {
  type        = string
  description = "The kubernetes namespace in which to provision the MetalLb Kubernetes External Load Balancer."
  default     = "k8s-cluster-decoderleco"
}


# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > TOPOLVM 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# --- > --- > --- > --- > --- > --- > --- > --- > 
# 

variable "topolvm_vol_grp_name" {
  type        = string
  description = "The name of the volume group that TopoLVM will use, to provision LVM logical volumes - based Kubernetes Persistent Volumes."
  default     = "vg-decoderleco"
}
variable "topolvm_disk_device_name" {
  type        = string
  description = "The Linux full device path, of the disk which Topolvm is going to use: in which the LVM Volume Group used by topoLVM will be created."
  default     = "/dev/sdc"
}


variable "topolvm_k8s_namespace" {
  type        = string
  description = "The kubernetes namespace in which to provision the TOPOLVM Kubernetes CSI driver."
  default     = "topolvm-system"
}

# --- 
#  https://go.dev/dl/
variable "topolvm_csi_golang_version" {
  type        = string
  description = "The Golang version to use to build from source the TOPOLVM Kubernetes CSI driver, and its docker image."
  default     = "1.22.4"
}

