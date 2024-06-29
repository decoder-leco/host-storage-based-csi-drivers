#!/bin/bash

# set -uxo pipefail
set -o errexit

# ---
#   https://rook.io/docs/rook/latest-release/CRDs/Cluster/ceph-cluster-crd/?h=crd#mon-settings
#   https://rook.io/docs/rook/latest-release/CRDs/Cluster/ceph-cluster-crd/?h=crd#osd-topology
# ---
# we have 3 zones :
# - 
#  zone-A, zone-B, zone-C
# - 
# we have 3 racks in first zone, and
# 2 racks in the other 2 zones so
# 7 racks, to spread 7 cluster nodes :
# - 
#  zone-A-rack1,
#  zone-A-rack2,
#  zone-A-rack3
# - 
#  zone-B-rack1,
#  zone-B-rack2,
# - 
#  zone-C-rack1,
#  zone-C-rack2,
# - 
# export KND_CLUSTER_NAME="k8s-cluster-decoderleco"
export KND_CLUSTER_NAME=$1
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> CEPH CLUSTER TOPOLOGY - KND_CLUSTER_NAME=[${KND_CLUSTER_NAME}]"
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
if [ "x${KND_CLUSTER_NAME}" == "x" ]; then
  echo "ERROR! The 'KND_CLUSTER_NAME' env. var. must be set, but is not!"
  echo "Provide the value of KND_CLUSTER_NAME as first argument of this script"
  exit 7
fi;

# export KND_CLUSTER_NODE1="${KND_CLUSTER_NAME}-worker1"
export KND_CLUSTER_NODE1="${KND_CLUSTER_NAME}-worker"
export KND_CLUSTER_NODE2="${KND_CLUSTER_NAME}-worker2"
export KND_CLUSTER_NODE3="${KND_CLUSTER_NAME}-worker3"
export KND_CLUSTER_NODE4="${KND_CLUSTER_NAME}-worker4"
export KND_CLUSTER_NODE5="${KND_CLUSTER_NAME}-worker5"
export KND_CLUSTER_NODE6="${KND_CLUSTER_NAME}-worker6"
export KND_CLUSTER_NODE7="${KND_CLUSTER_NAME}-worker7"

# ----------
#  To define the bumblebee topology, for the "topology explorer app", I will:
# + label all worker nodes 1,2,3 with label "topology.bumblebee.io/space=bumble-node"

kubectl label node ${KND_CLUSTER_NODE1} topology.bumblebee.io/galaxy=milkyway
kubectl label node ${KND_CLUSTER_NODE2} topology.bumblebee.io/galaxy=milkyway
kubectl label node ${KND_CLUSTER_NODE3} topology.bumblebee.io/galaxy=milkyway
kubectl label node ${KND_CLUSTER_NODE4} topology.bumblebee.io/galaxy=milkyway
kubectl label node ${KND_CLUSTER_NODE5} topology.bumblebee.io/galaxy=milkyway
kubectl label node ${KND_CLUSTER_NODE6} topology.bumblebee.io/galaxy=milkyway
kubectl label node ${KND_CLUSTER_NODE7} topology.bumblebee.io/galaxy=milkyway


# --- 


kubectl label node ${KND_CLUSTER_NODE1} topology.bumblebee.io/planet=bumble-planet-1
kubectl label node ${KND_CLUSTER_NODE2} topology.bumblebee.io/planet=bumble-planet-2
kubectl label node ${KND_CLUSTER_NODE3} topology.bumblebee.io/planet=bumble-planet-3
kubectl label node ${KND_CLUSTER_NODE4} topology.bumblebee.io/planet=bumble-planet-4
kubectl label node ${KND_CLUSTER_NODE5} topology.bumblebee.io/planet=bumble-planet-5
kubectl label node ${KND_CLUSTER_NODE6} topology.bumblebee.io/planet=bumble-planet-6
kubectl label node ${KND_CLUSTER_NODE7} topology.bumblebee.io/planet=bumble-planet-7


# --- 


kubectl label node ${KND_CLUSTER_NODE1} topology.bumblebee.io/planet-type=telluric
kubectl label node ${KND_CLUSTER_NODE2} topology.bumblebee.io/planet-type=telluric
kubectl label node ${KND_CLUSTER_NODE3} topology.bumblebee.io/planet-type=telluric
kubectl label node ${KND_CLUSTER_NODE4} topology.bumblebee.io/planet-type=gaseous
kubectl label node ${KND_CLUSTER_NODE5} topology.bumblebee.io/planet-type=gaseous
kubectl label node ${KND_CLUSTER_NODE6} topology.bumblebee.io/planet-type=gaseous
kubectl label node ${KND_CLUSTER_NODE7} topology.bumblebee.io/planet-type=gaseous