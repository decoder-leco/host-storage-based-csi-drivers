#!/bin/bash


set -o errexit

source ~/.bashrc


ls -alh  ~/.topolvm_provisioning.env.sh

source ~/.topolvm_provisioning.env.sh || true

# ---
#  

export TOPOLVM_K8S_NS=$(cat ~/.topolvm_provisioning.env.sh | grep 'TOPOLVM_K8S_NS' | awk -F '=' '{ print $NF }' | sed 's#"##g')
export TOPOLVM_VOL_GRP_NAME=$(cat ~/.topolvm_provisioning.env.sh | grep 'TOPOLVM_VOL_GRP_NAME' | awk -F '=' '{ print $NF }' | sed 's#"##g')

if [ "x${TOPOLVM_K8S_NS}" == "x" ]; then
  echo "ERROR! The 'TOPOLVM_K8S_NS' env. var. must be set, but is not!"
  exit 7
fi;

if [ "x${TOPOLVM_VOL_GRP_NAME}" == "x" ]; then
  echo "ERROR!!! The 'TOPOLVM_VOL_GRP_NAME' env. var. is not set!"
  exit 7
fi;


echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> TOPOLVM PROVISIONING - TOPOLVM_K8S_NS=[${TOPOLVM_K8S_NS}]"
echo "### >>> TOPOLVM PROVISIONING - TOPOLVM_VOL_GRP_NAME=[${TOPOLVM_VOL_GRP_NAME}]"
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

export CERT_MNGR_VERSION=${CERT_MNGR_VERSION:-"v1.14.7"}
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/${CERT_MNGR_VERSION}/cert-manager.crds.yaml || true

## TODO: NEED TO ADD DOCKER PULLING ALL REQUIRED IMAGES
# ghcr.io/topolvm/topolvm-with-sidecar:0.30.0
# 
# 

helm install --namespace=${TOPOLVM_K8S_NS} \
    topolvm topolvm/topolvm \
    --set cert-manager.enabled=false \
    --set lvmd.deviceClasses[0].name="hdd" \
    --set lvmd.deviceClasses[0].volume-group="${TOPOLVM_VOL_GRP_NAME}"
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

kubectl get pod -n topolvm-system

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