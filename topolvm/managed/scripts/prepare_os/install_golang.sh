#!/bin/bash


set -o errexit

source ~/.bashrc


ls -alh  ~/.topolvm_provisioning.env.sh

source ~/.topolvm_provisioning.env.sh || true

# ---
#  
export TOPOLVM_CSI_GOLANG_VERSION=$(cat ~/.topolvm_provisioning.env.sh | grep 'TOPOLVM_CSI_GOLANG_VERSION' | awk -F '=' '{ print $NF }' | sed 's#"##g')



# --- # --- # --- # --- 
# --- # --- # --- # --- 
# Install GOLANG
# --- # --- # --- # --- 
# --- # --- # --- # --- 



installGolang () {

if [ -f /usr/local/go ]; then
  sudo rm -f /usr/local/go
fi;
if [ -d /usr/local/go ]; then
  sudo rm -fr /usr/local/go
fi;
# --- 
#  https://go.dev/dl/
# - 
# https://go.dev/dl/go1.22.4.linux-amd64.tar.gz
# export GOLANG_TAR="https://go.dev/dl/go${TOPOLVM_CSI_GOLANG_VERSION}.linux-arm64.tar.gz"
export GOLANG_TAR="https://go.dev/dl/go${TOPOLVM_CSI_GOLANG_VERSION}.linux-amd64.tar.gz"
if [ -f ./go${TOPOLVM_CSI_GOLANG_VERSION}.linux-amd64.tar.gz ]; then
  sudo rm -f ./go${TOPOLVM_CSI_GOLANG_VERSION}.linux-amd64.tar.gz
fi;

curl -LO ${GOLANG_TAR}

# ls -alh ./go${TOPOLVM_CSI_GOLANG_VERSION}.linux-arm64.tar.gz
ls -alh ./go${TOPOLVM_CSI_GOLANG_VERSION}.linux-amd64.tar.gz

if [ -f /usr/local/go ]; then
  sudo rm -f /usr/local/go
fi;
if [ -d /usr/local/go ]; then
  sudo rm -fr /usr/local/go
fi;
# sudo tar -C /usr/local -xzf ./go${TOPOLVM_CSI_GOLANG_VERSION}.linux-arm64.tar.gz
sudo tar -C /usr/local -xzf ./go${TOPOLVM_CSI_GOLANG_VERSION}.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

echo 'export PATH=$PATH:/usr/local/go/bin' | tee -a ~/.bashrc

go version

}

figlet 'Install Golang'
export PATH=$PATH:/usr/local/go/bin
export CHECK_GOLANG_INSTALL=$(go version)
echo "  ---  CHECK_GOLANG_INSTALL=[${CHECK_GOLANG_INSTALL}]"

if [ "x${CHECK_GOLANG_INSTALL}" == "x" ]; then
  installGolang
else
  echo "Golang is already installed"
  export PATH=$PATH:/usr/local/go/bin
  go version
  exit 0
fi;