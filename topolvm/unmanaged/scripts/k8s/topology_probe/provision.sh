#!/bin/bash


set -o errexit

source ~/.bashrc

mkdir -p ~/.probe

cd ~/.probe

cp ~/.topology_probe.env.sh ~/.probe/

ls -alh  ~/.topology_probe.env.sh

source ~/.topology_probe.env.sh || true

# ---
#  

export DESIRED_STORAGE_CLASS=$(cat ~/.topology_probe.env.sh | grep 'DESIRED_STORAGE_CLASS' | awk -F '=' '{ print $NF }' | sed 's#"##g')
export TOPOLOGY_PROBE_DEPLOY_YAML=$(cat ~/.topology_probe.env.sh | grep 'TOPOLOGY_PROBE_DEPLOY_YAML' | awk -F '=' '{ print $NF }' | sed 's#"##g')



if [ "x${DESIRED_STORAGE_CLASS}" == "x" ]; then
  echo "ERROR! The 'DESIRED_STORAGE_CLASS' env. var. must be set, but is not!"
  exit 7
fi;

if [ "x${TOPOLOGY_PROBE_DEPLOY_YAML}" == "x" ]; then
  echo "ERROR! The 'TOPOLOGY_PROBE_DEPLOY_YAML' env. var. must be set, but is not!"
  exit 7
fi;

echo "######################################################"
echo "######################################################"
echo "######################################################"
echo "######  DESIRED_STORAGE_CLASS=[${DESIRED_STORAGE_CLASS}]"
echo "######  TOPOLOGY_PROBE_DEPLOY_YAML=[${TOPOLOGY_PROBE_DEPLOY_YAML}]"
echo "######################################################"
echo "######################################################"
echo "######################################################"
echo "######################################################"

# export TEST_IMG="stefanscherer/whoami:linux-arm64-2.0.1"
export TEST_IMG="traefik/whoami"
docker pull --platform linux/amd64 ${TEST_IMG} || true

docker tag ${TEST_IMG} localhost:5001/${TEST_IMG}

docker push localhost:5001/${TEST_IMG}

# envsubst < ${TOPOLOGY_PROBE_DEPLOY_YAML} > ${TOPOLOGY_PROBE_DEPLOY_YAML}
envsubst < ${TOPOLOGY_PROBE_DEPLOY_YAML} > ./interpolated.deploy.probe.yaml

# kubectl delete -f ${TOPOLOGY_PROBE_DEPLOY_YAML} || true
kubectl delete -f ./interpolated.deploy.probe.yaml || true
kubectl delete ns topology-probe-tests || true

kubectl create ns topology-probe-tests || true

# kubectl apply -f ${TOPOLOGY_PROBE_DEPLOY_YAML} || true
kubectl apply -f ./interpolated.deploy.probe.yaml || true
