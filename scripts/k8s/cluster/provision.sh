#!/bin/bash
set -o errexit

source ~/.bashrc


ls -alh  ~/.k8s_cluster_provision.env.sh

source ~/.k8s_cluster_provision.env.sh || true

# ---
#  
export OCI_REGISTRY_CONTAINER_NAME=$(cat ~/.k8s_cluster_provision.env.sh | grep 'OCI_REGISTRY_CONTAINER_NAME' | awk -F '=' '{ print $NF }' | sed 's#"##g')
export OCI_REGISTRY_PORT=$(cat ~/.k8s_cluster_provision.env.sh | grep 'OCI_REGISTRY_PORT' | awk -F '=' '{ print $NF }' | sed 's#"##g')
export KND_CLUSTER_NAME=$(cat ~/.k8s_cluster_provision.env.sh | grep 'KND_CLUSTER_NAME' | awk -F '=' '{ print $NF }' | sed 's#"##g')
export KND_CLUSTER_CONFIG_FILE=$(cat ~/.k8s_cluster_provision.env.sh | grep 'KND_CLUSTER_CONFIG_FILE' | awk -F '=' '{ print $NF }' | sed 's#"##g')

if [ "x${KND_CLUSTER_CONFIG_FILE}" == "x" ]; then
  echo "ERROR! The 'KND_CLUSTER_CONFIG_FILE' env. var. must be set, but is not!"
  exit 7
fi;

if [ "x${KND_CLUSTER_NAME}" == "x" ]; then
  echo "ERROR!!! The 'KND_CLUSTER_NAME' env. var. is not set!"
  exit 7
fi;

if [ "x${OCI_REGISTRY_PORT}" == "x" ]; then
  echo "ERROR!!! The 'OCI_REGISTRY_PORT' env. var. is not set!"
  exit 7
fi;

if [ "x${OCI_REGISTRY_CONTAINER_NAME}" == "x" ]; then
  echo "ERROR!!! The 'OCI_REGISTRY_CONTAINER_NAME' env. var. is not set!"
  exit 7
fi;

echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> KIND CLUSTER PROVISIONING - KND_CLUSTER_CONFIG_FILE=[${KND_CLUSTER_CONFIG_FILE}]"
echo "### >>> KIND CLUSTER PROVISIONING - KND_CLUSTER_NAME=[${KND_CLUSTER_NAME}]"
echo "### >>> KIND CLUSTER PROVISIONING - OCI_REGISTRY_PORT=[${OCI_REGISTRY_PORT}]"
echo "### >>> KIND CLUSTER PROVISIONING - OCI_REGISTRY_CONTAINER_NAME=[${OCI_REGISTRY_CONTAINER_NAME}]"
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "

# ---
# KND_NET_NAME: the name of the docker network 
# used by the kind cluster. It cannot be
# changed, it is kind and that's it.
# it is created by kind as the cluster
# create command is executed. Don't try and create it before.
# ---
# export KND_NET_NAME="kind"
# export KND_CLUSTER_NAME="k8s-cluster-decoderleco"





sudo mkdir -p /usr/local/bin/



# 1./ Install arkade
figlet 'Install arkade'

curl -sLS https://get.arkade.dev | sudo sh

arkade version


# 2./ Install kind

figlet 'Install kind'


if ! [ -f /usr/local/bin/kind ]; then
  arkade get kind
  sudo mv ${HOME}/.arkade/bin/kind /usr/local/bin/
else
  figlet 'kind already installed'
  ls -alh /usr/local/bin/kind
fi;

kind version

# 2./ Install kubectl and helm

figlet 'Install kubectl'

if ! [ -f /usr/local/bin/kubectl ]; then
  arkade get kubectl
  sudo mv ${HOME}/.arkade/bin/kubectl /usr/local/bin/
else
  figlet 'kubectl already installed'
  ls -alh /usr/local/bin/kubectl
fi;


kubectl version --client


figlet 'Install helm'

if ! [ -f /usr/local/bin/helm ]; then
  arkade get helm
  sudo mv ${HOME}/.arkade/bin/helm /usr/local/bin/
else
  figlet 'helm already installed'
  ls -alh /usr/local/bin/helm
fi;


helm version
# version.BuildInfo{Version:"v3.14.4", GitCommit:"81c902a123462fd4052bc5e9aa9c513c4c8fc142", GitTreeState:"clean", GoVersion:"go1.21.9"}

# 4./ create kind kubernetes cluster, with a local docker registry

figlet 'Create kubernetes cluster'
echo "Just before creating cluster: KND_CLUSTER_NAME=[${KND_CLUSTER_NAME}]"
kind delete clusters --all
# 2. Create kind cluster with containerd registry config dir enabled
# TODO: kind will eventually enable this by default and this patch will
# be unnecessary.
#
# See:
# https://github.com/kubernetes-sigs/kind/issues/2875
# https://github.com/containerd/containerd/blob/main/docs/cri/config.md#registry-configuration
# See: https://github.com/containerd/containerd/blob/main/docs/hosts.md
# https://kind.sigs.k8s.io/docs/user/configuration#extra-mounts
# extraMounts of /etc/localtime and /etc/timezone are there for later deployment of https://github.com/k8tz/k8tz
# ---
#  to change KND_CLUSTER_CONFIG_FILE: edit the 'cluster.yaml' in the same folder than this script


# -- about /etc/localtime, I may get that error, which i want to avoid:
# 
#   docker: Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: error mounting "/etc/localtime" to rootfs at "/etc/localtime": mount /etc/localtime:/etc/localtime (via /proc/self/fd/7), flags: 0x5000: not a directory: unknown: Are you trying to mount a directory onto a file (or vice-versa)? Check if the specified host path exists and is the expected type.
# -
# if that error happens, that would be because the /etc/localtime file does not exist on the system, so i have to test that

if [ -f /etc/localtime ]; then
  echo "Okay, /etc/localtime does exists"
  ls -alh /etc/localtime
  export TARGET_OF_LOCALTIME_SYMLINK=$(sudo ls -alh /etc/localtime | awk '{ print $NF }')
  echo " TARGET_OF_LOCALTIME_SYMLINK=[${TARGET_OF_LOCALTIME_SYMLINK}]"
  ls -alh ${TARGET_OF_LOCALTIME_SYMLINK}
fi;


# ---
#  First we create all the folders mounte in the kind cluser nodes, which are subfolders of the ${OPENEBS_CSI_DISK_MOUNT_POINT} Folder
ls -alh ${KND_CLUSTER_CONFIG_FILE}

# cat ${KND_CLUSTER_CONFIG_FILE} | yq '.nodes[].extraMounts.[]  | select( .hostPath | contains("OPENEBS_CSI_DISK_MOUNT_POINT"))' | grep hostPath | awk -F ': ' '{ print $NF }' > ./list.of.path.to.mount.on.each.cluster.nodes.list
cat ${KND_CLUSTER_CONFIG_FILE} | yq '.nodes[].extraMounts.[]  | select( .hostPath | contains("ROOK_CSI_DISK_MOUNT_POINT"))' | grep hostPath | awk -F ': ' '{ print $NF }' > ./list.of.path.to.mount.on.each.cluster.nodes.list

while read FOLDER_PATH; do
  echo ">>>>> Creating [${FOLDER_PATH}] as folder to mount on kind cluster nodes"
  sudo mkdir -p ${FOLDER_PATH}
  sudo chown $USER:$USER -R ${FOLDER_PATH}
done <./list.of.path.to.mount.on.each.cluster.nodes.list

# - # - # - # - # - # - # - # - # - # - # - # - # - 
# - # - # - # - # - # - # - # - # - # - # - # - # - 
# - # - # -
# Then envsubst will interpolate the value of
# any env. var. used in the cluster config file, like
# OPENEBS_CSI_DISK_MOUNT_POINT or
# ROOK_CSI_DISK_MOUNT_POINT, in the 
# cluster config file, if they are used
# (for now they are not)
# - # - # -
# - # - # - # - # - # - # - # - # - # - # - # - # - 
# - # - # - # - # - # - # - # - # - # - # - # - # - 

envsubst < ${KND_CLUSTER_CONFIG_FILE} > ./interpolated.cluster.yaml

cat ./interpolated.cluster.yaml | yq .

# ---
# And now the cluster is ready to create

kind create cluster -n "${KND_CLUSTER_NAME}" --wait 25m --config=./interpolated.cluster.yaml

# Then we wait a bit to let the cluster get up'n running cosily
sleep 60s

kubectl cluster-info




# cat <<EOF | kind create cluster -n ${KND_CLUSTER_NAME} --config=-
# kind: Cluster
# apiVersion: kind.x-k8s.io/v1alpha4
# containerdConfigPatches:
# - |-
#   [plugins."io.containerd.grpc.v1.cri".registry]
#     config_path = "/etc/containerd/certs.d"
# EOF






# 3. Add the registry config to the nodes
#
# This is necessary because localhost resolves to loopback addresses that are
# network-namespace local.
# In other words: localhost in the container is not localhost on the host.
#
# We want a consistent name that works from both ends, so we tell containerd to
# alias localhost:${OCI_REGISTRY_PORT} to the registry container when pulling images
REGISTRY_DIR="/etc/containerd/certs.d/localhost:${OCI_REGISTRY_PORT}"
for node in $(kind get nodes -n ${KND_CLUSTER_NAME}); do
  docker exec "${node}" mkdir -p "${REGISTRY_DIR}"
  cat <<EOF | docker exec -i "${node}" cp /dev/stdin "${REGISTRY_DIR}/hosts.toml"
[host."http://${OCI_REGISTRY_CONTAINER_NAME}:5000"]
EOF
done

# 4. Connect the registry to the cluster network if not already connected
# This allows kind to bootstrap the network but ensures they're on the same network
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${OCI_REGISTRY_CONTAINER_NAME}")" = 'null' ]; then
  docker network connect "kind" "${OCI_REGISTRY_CONTAINER_NAME}"
fi

# 5. Document the local registry
# https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${OCI_REGISTRY_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF



figlet 'Test cluster + registry'

# https://github.com/traefik/whoami
# https://hub.docker.com/r/stefanscherer/whoami/tags?page=&page_size=&ordering=&name=arm
# stefanscherer's docker image is badly tagged for linux/amd64 even for his arm releases, but it will still do for the test.
# export TEST_IMG="stefanscherer/whoami:linux-arm64-2.0.1"
export TEST_IMG="traefik/whoami:v1.10"

# docker pull --platform linux/arm64 ${TEST_IMG} || true
docker pull ${TEST_IMG} || true

docker tag ${TEST_IMG} localhost:5001/${TEST_IMG}

docker push localhost:5001/${TEST_IMG}

docker rmi localhost:5001/${TEST_IMG} --force

kubectl create ns test

kubectl -n test create deployment whoami-server --image=localhost:5001/${TEST_IMG}

kubectl -n test get all



exit 0

(kindest/node:v1.30.0)