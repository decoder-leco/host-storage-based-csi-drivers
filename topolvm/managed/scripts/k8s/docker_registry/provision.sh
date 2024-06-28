#!/bin/bash
# set -uxo pipefail
set -o errexit

source ~/.bashrc

ls -alh  ~/.oci_registry_provision.env.sh

source ~/.oci_registry_provision.env.sh || true

export OCI_REGISTRY_CONTAINER_NAME=$(cat ~/.oci_registry_provision.env.sh | grep 'OCI_REGISTRY_CONTAINER_NAME' | awk -F '=' '{ print $NF }' | sed 's#"##g')
export OCI_REGISTRY_PORT=$(cat ~/.oci_registry_provision.env.sh | grep 'OCI_REGISTRY_PORT' | awk -F '=' '{ print $NF }' | sed 's#"##g')

if [ "x${OCI_REGISTRY_PORT}" == "x" ]; then
  echo "ERROR!!! The 'OCI_REGISTRY_PORT' env. var. is not set!"
  exit 7
fi;

if [ "x${OCI_REGISTRY_CONTAINER_NAME}" == "x" ]; then
  echo "ERROR!!! The 'OCI_REGISTRY_CONTAINER_NAME' env. var. is not set!"
  exit 7
fi;


# 1. Create registry container unless it already exists
export OCI_REGISTRY_CONTAINER_NAME=${OCI_REGISTRY_CONTAINER_NAME:-'kind-registry'}
export OCI_REGISTRY_PORT=${OCI_REGISTRY_PORT:-'5001'}

if [ "$(docker inspect -f '{{.State.Running}}' "${OCI_REGISTRY_CONTAINER_NAME}" 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${OCI_REGISTRY_PORT}:5000" --network bridge --name "${OCI_REGISTRY_CONTAINER_NAME}" \
    registry:2
fi


figlet 'Test registry'
export TEST_IMG="alpine"

docker pull --platform linux/arm64 ${TEST_IMG}

docker tag ${TEST_IMG} localhost:5001/${TEST_IMG}

docker push localhost:5001/${TEST_IMG}

docker rmi localhost:5001/${TEST_IMG} --force
