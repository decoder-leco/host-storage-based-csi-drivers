#!/bin/bash


set -o errexit

source ~/.bashrc


ls -alh  ~/.topolvm_provisioning.env.sh

source ~/.topolvm_provisioning.env.sh || true

# ---
#  

export TOPOLVM_K8S_NS=$(cat ~/.topolvm_provisioning.env.sh | grep 'TOPOLVM_K8S_NS' | awk -F '=' '{ print $NF }' | sed 's#"##g')
export TOPOLVM_VOL_GRP_NAME=$(cat ~/.topolvm_provisioning.env.sh | grep 'TOPOLVM_VOL_GRP_NAME' | awk -F '=' '{ print $NF }' | sed 's#"##g')
export TOPOLVM_DESIRED_VERSION=$(cat ~/.topolvm_provisioning.env.sh | grep 'TOPOLVM_DESIRED_VERSION' | awk -F '=' '{ print $NF }' | sed 's#"##g')
export LVM_THINPOOL_NAME=$(cat ~/.topolvm_provisioning.env.sh | grep 'LVM_THINPOOL_NAME' | awk -F '=' '{ print $NF }' | sed 's#"##g')



if [ "x${TOPOLVM_K8S_NS}" == "x" ]; then
  echo "ERROR! The 'TOPOLVM_K8S_NS' env. var. must be set, but is not!"
  exit 7
fi;

if [ "x${TOPOLVM_VOL_GRP_NAME}" == "x" ]; then
  echo "ERROR!!! The 'TOPOLVM_VOL_GRP_NAME' env. var. is not set!"
  exit 7
fi;

if [ "x${TOPOLVM_DESIRED_VERSION}" == "x" ]; then
  echo "ERROR!!! The 'TOPOLVM_DESIRED_VERSION' env. var. is not set!"
  exit 7
fi;

if [ "x${LVM_THINPOOL_NAME}" == "x" ]; then
  echo "ERROR! The 'LVM_THINPOOL_NAME' env. var. must be set, but is not!"
  exit 7
fi;

echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> TOPOLVM PROVISIONING - TOPOLVM_K8S_NS=[${TOPOLVM_K8S_NS}]"
echo "### >>> TOPOLVM PROVISIONING - TOPOLVM_VOL_GRP_NAME=[${TOPOLVM_VOL_GRP_NAME}]"
echo "### >>> TOPOLVM PROVISIONING - TOPOLVM_DESIRED_VERSION=[${TOPOLVM_DESIRED_VERSION}]"
echo "### >>> TOPOLVM PROVISIONING - LVM_THINPOOL_NAME=[${LVM_THINPOOL_NAME}]"
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "


###############################
## First LVM must be 
#  installed and a 
#  Volume Group must be 
#  created with a name defined
#  by an env. var.
###############################

###############################
## Then a dedicated namespace
#  must be created to 
#  provision topolvm into
# - 
#  the namespace must be 
#  labelled 
###############################
# https://github.com/topolvm/topolvm/blob/main/docs/getting-started.md

kubectl create ns ${TOPOLVM_K8S_NS} || true
kubectl label namespace ${TOPOLVM_K8S_NS} topolvm.io/webhook=ignore || true
kubectl label namespace kube-system topolvm.io/webhook=ignore || true


helm repo add topolvm https://topolvm.github.io/topolvm || true
helm repo update || true

helm delete topolvm -n topolvm-system || true

# Cert manager crds are required even if cert manager is disabled in helm chart values.
export CERT_MNGR_VERSION=${CERT_MNGR_VERSION:-"v1.14.7"}
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/${CERT_MNGR_VERSION}/cert-manager.crds.yaml || true

## TODO: NEED TO ADD DOCKER PULLING ALL REQUIRED IMAGES
# ghcr.io/topolvm/topolvm-with-sidecar:0.30.0
# 
# - there is only one docker image
# Docker pulling ghcr.io/topolvm/topolvm-with-sidecar:0.30.0 is very long, so
# instead we will build from source topolvm and its docker image
###

export TOPOLVM_BUILD_FROM_SRC_HOME=$(mktemp -d -t XXXXXX_TOPOLVM_BUILD_FROM_SRC)
echo " > TOPOLVM_BUILD_FROM_SRC_HOME=[${TOPOLVM_BUILD_FROM_SRC_HOME}]"


export TOPOLVM_DESIRED_VERSION="0.30.0"

# export TOPOLVM_VERSION="v${TOPOLVM_DESIRED_VERSION}"
export TOPOLVM_VERSION="${TOPOLVM_DESIRED_VERSION}"
echo "#####################################"
echo "# TOPOLVM_VERSION=[${TOPOLVM_VERSION}]"
echo "#####################################"


topoLVMbuildFromSrc_gitClone () {


# git clone https://github.com/topolvm/topolvm.git ${TOPOLVM_BUILD_FROM_SRC_HOME}

git clone --depth 1 --branch v${TOPOLVM_DESIRED_VERSION} https://github.com/topolvm/topolvm.git ${TOPOLVM_BUILD_FROM_SRC_HOME}

cd ${TOPOLVM_BUILD_FROM_SRC_HOME}

# git checkout v${TOPOLVM_DESIRED_VERSION}
}

topoLVMbuildFromSrc () {
source ~/.bashrc
export PATH=$PATH:/usr/local/go/bin
export GOBIN=/usr/local/go/bin

echo "#####################################"
echo "# TOPOLVM: make setup"
echo "#####################################"

make setup



echo "#####################################"
echo "# TOPOLVM: Golang Build from source"
echo "#####################################"

make build/lvmd TOPOLVM_VERSION=${TOPOLVM_DESIRED_VERSION}
tar czf lvmd-${TOPOLVM_DESIRED_VERSION}.tar.gz -C ./build lvmd

}

topoLVMDockerBuild () {
# ---
# build docker images
echo "#####################################"
echo "# TOPOLVM: Build Docker Images"
echo "#####################################"
echo "# List Docker buildx supported platforms"
echo "##"
docker buildx ls
echo "#####################################"

# BUILDX_PUSH_OPTIONS := "-o type=tar,dest=build/topolvm.tar"

export TOPOLVM_OCI_REG_FQDN="ghcr.io"
export TOPOLVM_IMG_NAME="topolvm/topolvm"
export TOPOLVM_IMG_TAG="0.30.0"
export TOPOLVM_IMG_GUN="${TOPOLVM_OCI_REG_FQDN}/${TOPOLVM_IMG_NAME}:${TOPOLVM_IMG_TAG}"

# --- >

mkdir -p build
# docker build --no-cache \
docker build \
	--platform linux/amd64 \
	-t ${TOPOLVM_IMG_GUN} \
	--build-arg TOPOLVM_VERSION=${TOPOLVM_DESIRED_VERSION} \
	--target topolvm \
  .


export TOPOLVM_OCI_REG_FQDN="ghcr.io"
export TOPOLVM_IMG_NAME="topolvm/topolvm-with-sidecar"
export TOPOLVM_IMG_TAG="0.30.0"
export TOPOLVM_IMG_GUN="${TOPOLVM_OCI_REG_FQDN}/${TOPOLVM_IMG_NAME}:${TOPOLVM_IMG_TAG}"

mkdir -p build
# docker build --no-cache \
docker build \
	--platform linux/amd64 \
	-t ${TOPOLVM_IMG_GUN} \
	--build-arg TOPOLVM_VERSION=${TOPOLVM_DESIRED_VERSION} \
	--target topolvm-with-sidecar \
  .

# make multi-platform-image-normal
# make multi-platform-image-with-sidecar
docker images | grep topolvm

}

figlet 'TopoLVM Build From Source'

topoLVMbuildFromSrc_gitClone

# topoLVMbuildFromSrc

topoLVMDockerBuild

# echo "DEBUG STOP"
# exit 0

export CHECK_TOPOLVM_IMG_EXIST=$(docker images | grep topolvm)
export CHECK_TOPOLVM_SIDECAR_IMG_EXIST=$(docker images | grep 'topolvm-with-sidecar')

# if [ "x${CHECK_TOPOLVM_IMG_EXIST}" == "x" ]; then
#   topoLVMbuildFromSrc
# else 
#   echo "TopoLVM images - already exist"
#   docker images | grep topolvm
# fi;

# echo "DEBUG STOP"
# exit 0


###
export TOPOLVM_OCI_REG_FQDN="ghcr.io"
export TOPOLVM_IMG_NAME="topolvm/topolvm-with-sidecar"
export TOPOLVM_IMG_TAG="0.30.0"
export TOPOLVM_IMG_GUN="${TOPOLVM_OCI_REG_FQDN}/${TOPOLVM_IMG_NAME}:${TOPOLVM_IMG_TAG}"
export TOPOLVM_IMG_GUN_TO_PUSH="localhost:5001/${TOPOLVM_IMG_NAME}:${TOPOLVM_IMG_TAG}"
# docker pull --platform linux/arm64 ${TOPOLVM_IMG_GUN}
# docker pull --platform linux/amd64 ${TOPOLVM_IMG_GUN}
docker tag ${TOPOLVM_IMG_GUN} ${TOPOLVM_IMG_GUN_TO_PUSH}
docker push ${TOPOLVM_IMG_GUN_TO_PUSH}
docker rmi ${TOPOLVM_IMG_GUN_TO_PUSH} --force
docker rmi ${TOPOLVM_IMG_GUN} --force



# ---
#  Cert manager images
# - 
#  quay.io/jetstack/cert-manager-ctl:v1.7.0
#  quay.io/jetstack/cert-manager-cainjector:v1.7.0
#  quay.io/jetstack/cert-manager-controller:v1.7.0
#  quay.io/jetstack/cert-manager-webhook:v1.7.0

# ---
# LAST THING TO ADJUST: 
#  > add storage class for the "hdd-thin" instead of "ssd-thin"
#  > I will test if it works if I set lvmd.managed=true
#  The other paramters are identical, except the replica count
# exit 37
cat <<EOF >./values.yaml
# controller:
#   replicaCount: 1
image:
  repository: localhost:5001/${TOPOLVM_IMG_NAME}
  tag: ${TOPOLVM_IMG_TAG}
lvmd:
  managed: false
  # lvmd.deviceClasses -- Specify the device-class settings.
  deviceClasses:
    - name: hdd
      volume-group: ${TOPOLVM_VOL_GRP_NAME}
      default: true
      # the 'spare-gb' parameter must match the value set in the [/topolvm/run/lvmd.yaml]
      spare-gb: 10
  deviceClasses:
    - name: hdd-thin
      volume-group: ${TOPOLVM_VOL_GRP_NAME}
      default: false
      # the below parameters must match the value set in the [/topolvm/run/lvmd.yaml]
      type: thin
      thin-pool:
        name: ${LVM_THINPOOL_NAME}
        overprovision-ratio: 10.0

cert-manager:
  enabled: true

storageClasses:
  - name: topolvm-provisioner
    storageClass:
      fsType: xfs
      isDefaultClass: false
      volumeBindingMode: WaitForFirstConsumer
      allowVolumeExpansion: true
  - name: topolvm-provisioner-thin
    storageClass:
      fsType: xfs
      isDefaultClass: false
      volumeBindingMode: WaitForFirstConsumer
      allowVolumeExpansion: true
      additionalParameters:
        "topolvm.io/device-class": "hdd-thin"
      # additionalParameters:
      #   "topolvm.io/device-class": "ssd-thin"
EOF


# helm install --namespace=${TOPOLVM_K8S_NS} \
#     topolvm topolvm/topolvm \
#     --set cert-manager.enabled=true \
#     --set lvmd.deviceClasses[0].name="hdd" \
#     --set lvmd.deviceClasses[0].volume-group="${TOPOLVM_VOL_GRP_NAME}" \
#     --set image.repository="localhost:5001/${TOPOLVM_IMG_NAME}" \
#     --set image.tag="${TOPOLVM_IMG_TAG}"

# helm install --namespace=${TOPOLVM_K8S_NS} \
#     topolvm topolvm/topolvm \
#     --set cert-manager.enabled=true \
#     --set lvmd.deviceClasses[0].name="hdd" \
#     --set lvmd.deviceClasses[0].volume-group="${TOPOLVM_VOL_GRP_NAME}" \
#     --set image.repository="localhost:5001/${TOPOLVM_IMG_NAME}" \
#     --set image.tag="${TOPOLVM_IMG_TAG}"

    
helm install --namespace=${TOPOLVM_K8S_NS} \
    topolvm topolvm/topolvm \
    --values ./values.yaml
    
# helm upgrade --namespace=${TOPOLVM_K8S_NS} \
#     topolvm topolvm/topolvm \
#     --values ./values.yaml

kubectl wait --for=condition=available --timeout=120s -n ${TOPOLVM_K8S_NS} deployments/topolvm-controller
kubectl wait --for=condition=ready --timeout=120s -n ${TOPOLVM_K8S_NS} -l="app.kubernetes.io/component=controller,app.kubernetes.io/name=topolvm" pod
kubectl wait --for=condition=ready --timeout=120s -n ${TOPOLVM_K8S_NS} certificate/topolvm-mutatingwebhook

# cat values.yaml | yq '.lvmd.deviceClasses[0]["volume-group"]'
# ~$ cat values.yaml | yq '.["cert-manager"]' -y
# enabled: false
# # https://github.com/topolvm/topolvm/blob/main/charts/topolvm/values.yaml#L136
#   # lvmd.deviceClasses -- Specify the device-class settings.
#   deviceClasses:
#     - name: ssd
#       volume-group: myvg1
#       default: true
#       spare-gb: 10
sleep 5s

kubectl -n topolvm-system get pod
kubectl -n topolvm-system get all


figlet "Test TopoLVM"
# - 
# The Helm Chart automatically created
# a storage class named "topolvm-provisioner"
# - 
kubectl apply -f - <<EOF
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: my-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: topolvm-provisioner
---
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: pause
    image: registry.k8s.io/pause
    volumeMounts:
    - mountPath: /data
      name: volume
  volumes:
  - name: volume
    persistentVolumeClaim:
      claimName: my-pvc
EOF