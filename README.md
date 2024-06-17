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