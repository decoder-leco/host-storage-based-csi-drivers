# Host Storage based Csi Drivers benchmark

The goal of this benchmark is:

* for as many csi drivers as possible, which have one mandatory feature: The ability to provision persistent volumes, from multiple Kubernetes Cluster nodes storage resources.
* to provide a fully working automated provisioning recipe
* to compare those csi drivers accoding a set of criteria:
  * feature support:
    * csi snapshots
  * level of support:
    * date of the latest commit
    * date of the latest release
    * number of github/gitlab stars
    * exsitence of a helm chart

## TopoLVM

First, I studied TopoLVM. As I learned, TopoLVM can be provisioned in two different _"modes"_: either _managed_, or _unmanaged_.

* In the [`topolvm/unmanaged`](./topolvm/unmanaged) folder, you will find a recipe which successfully provisions a TopoLVM CSI driver stack, in the _unmanaged mode_, with Helm, into a Kind Kubernetes Cluster, from any Virtual MAchine you have SSH access to using an SSH Keypair.
* In the [`topolvm/managed`](./topolvm/managed) folder, you will soon find a recipe which successfully provisions a TopoLVM CSI driver stack, with Helm, into a Kind Kubernetes Cluster, from any Virtual Machine you have SSH access to using an SSH Keypair.
