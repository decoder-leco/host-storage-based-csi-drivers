#!/bin/bash
# set -uxo pipefail
set -o errexit

echo '>>> MAKE SURE NO SWAP'
sudo swapoff -a

echo '>>> INSTALL Utils Linux packages'

sudo apt-get update -y

sudo apt-get install -y curl bash git wget iputils-ping jq figlet yq gettext build-essential
