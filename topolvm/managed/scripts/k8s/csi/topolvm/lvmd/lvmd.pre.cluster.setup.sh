#!/bin/bash


set -o errexit

source ~/.bashrc


ls -alh  ~/.lvmd.setup.env.sh

source ~/.lvmd.setup.env.sh || true

# ---
#  

export TOPOLVM_VOL_GRP_NAME=$(cat ~/.lvmd.setup.env.sh | grep 'TOPOLVM_VOL_GRP_NAME' | awk -F '=' '{ print $NF }' | sed 's#"##g')
export TOPOLVM_DESIRED_VERSION=$(cat ~/.lvmd.setup.env.sh | grep 'TOPOLVM_DESIRED_VERSION' | awk -F '=' '{ print $NF }' | sed 's#"##g')
# export LVM_THINPOOL_NAME="thinpool"
export LVM_THINPOOL_NAME=$(cat ~/.lvmd.setup.env.sh | grep 'LVM_THINPOOL_NAME' | awk -F '=' '{ print $NF }' | sed 's#"##g')
export LVMD_HOME=$(cat ~/.lvmd.setup.env.sh | grep 'LVMD_HOME' | awk -F '=' '{ print $NF }' | sed 's#"##g')
# export LVMD_HOME=/opt/lvmd

# --- 
#  In [${LVMD_HOME}/bin/] will
#  be placed the lvmd executable
sudo mkdir -p ${LVMD_HOME}/bin/
# --- 
#  In [${LVMD_HOME}/run/] will
#  be placed the lvmd SystemD unit unix socket, and 
#  the lvmd yaml config file
sudo mkdir -p ${LVMD_HOME}/run/
# --- 
#  cf. https://github.com/topolvm/topolvm/blob/f6b7b2e45f4798497b0a3fb590aac8c2a026622c/example/Makefile#L80
#  Also, the kind cluster node will have extra mounts to the two below folders:
sudo rm -rf ${LVMD_HOME}/controller ${LVMD_HOME}/worker* || true
sudo mkdir -p ${LVMD_HOME}/controller
sudo mkdir -p ${LVMD_HOME}/worker1
sudo mkdir -p ${LVMD_HOME}/worker2
sudo mkdir -p ${LVMD_HOME}/worker3
sudo mkdir -p ${LVMD_HOME}/worker4
sudo mkdir -p ${LVMD_HOME}/worker5
sudo mkdir -p ${LVMD_HOME}/worker6
sudo mkdir -p ${LVMD_HOME}/worker7


if [ "x${TOPOLVM_VOL_GRP_NAME}" == "x" ]; then
  echo "ERROR!!! The 'TOPOLVM_VOL_GRP_NAME' env. var. is not set!"
  exit 7
fi;

if [ "x${TOPOLVM_DESIRED_VERSION}" == "x" ]; then
  echo "ERROR!!! The 'TOPOLVM_DESIRED_VERSION' env. var. is not set!"
  exit 7
fi;

if [ "x${LVM_THINPOOL_NAME}" == "x" ]; then
  echo "ERROR!!! The 'LVM_THINPOOL_NAME' env. var. is not set!"
  exit 7
fi;

if [ "x${LVMD_HOME}" == "x" ]; then
  echo "ERROR!!! The 'LVMD_HOME' env. var. is not set!"
  exit 7
fi;


echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> LVMD SETUP - TOPOLVM_VOL_GRP_NAME=[${TOPOLVM_VOL_GRP_NAME}]"
echo "### >>> LVMD SETUP - TOPOLVM_DESIRED_VERSION=[${TOPOLVM_DESIRED_VERSION}]"
echo "### >>> LVMD SETUP - LVM_THINPOOL_NAME=[${LVM_THINPOOL_NAME}]"
echo "### >>> LVMD SETUP - LVMD_HOME=[${LVMD_HOME}]"
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "




createThinPool () {

# --- # --- # --- # --- # --- 
# --- # --- # --- # --- 
# --- # --- # --- 
# --- # --- 
# ---  Create a thinpool
sudo lvcreate -T ${TOPOLVM_VOL_GRP_NAME}/${LVM_THINPOOL_NAME} -L 12G;
# --- I create that thin pool to do the
# --- same operation than: https://github.com/topolvm/topolvm/blob/f6b7b2e45f4798497b0a3fb590aac8c2a026622c/example/Makefile#L102C2-L102C44
# --- # --- 
# --- # --- # --- 
# --- # --- # --- # --- 
# --- # --- # --- # --- # --- 

}

buildLvmdromSrc () {
export LVMD_BUILD_FROM_SRC_HOME=$(mktemp -d -t XXXXXX_TOPOLVM_BUILD_FROM_SRC)
echo " > LVMD_BUILD_FROM_SRC_HOME=[${LVMD_BUILD_FROM_SRC_HOME}]"


# export TOPOLVM_DESIRED_VERSION="0.30.0"

# export TOPOLVM_VERSION="v${TOPOLVM_DESIRED_VERSION}"
export TOPOLVM_VERSION="${TOPOLVM_DESIRED_VERSION}"
echo "#####################################"
echo "# TOPOLVM_VERSION=[${TOPOLVM_VERSION}]"
echo "#####################################"


git clone --depth 1 --branch v${TOPOLVM_DESIRED_VERSION} https://github.com/topolvm/topolvm.git ${LVMD_BUILD_FROM_SRC_HOME}

cd ${LVMD_BUILD_FROM_SRC_HOME}

export PATH=$PATH:/usr/local/go/bin
go version

go build -o ./build/lvmd ./cmd/lvmd

sudo mv ./build/lvmd ${LVMD_HOME}/bin/

sudo chmod +x ${LVMD_HOME}/bin/lvmd

# ${LVMD_HOME}/bin/lvmd version

}


installLVMD () {

cat <<EOF >./lvmd.yaml
socket-name: /run/topolvm/lvmd.sock
device-classes:
  - name: hdd
    volume-group: $TOPOLVM_VOL_GRP_NAME
    default: true
    spare-gb: 10
  - name: hdd-thin
    volume-group: $TOPOLVM_VOL_GRP_NAME
    type: thin
    thin-pool:
      name: ${LVM_THINPOOL_NAME}
      overprovision-ratio: 10.0
EOF


# sed -e "s=/run/topolvm/lvmd.sock=${LVMD_HOME}/run/lvmd.sock=; s=spare-gb: 10=spare-gb: 1=" ./lvmd.yaml | tee ${LVMD_HOME}/run/lvmd.yaml
sed -e "s=/run/topolvm/lvmd.sock=${LVMD_HOME}/run/lvmd.sock=; s=spare-gb: 10=spare-gb: 10=" ./lvmd.yaml | sudo tee ${LVMD_HOME}/run/lvmd.yaml

# ---
# Creating the SystemD unit for 
# lvmd process: when that unit starts, it
# will create the unix socket used by topolvm.
# -
sudo systemctl stop lvmd.service || true
sudo systemctl disable lvmd || true
sudo rm /etc/systemd/system/lvmd.service || true
# and symlinks that might be related
sudo rm /etc/systemd/system/lvmd.service || true
sudo rm /usr/lib/systemd/system/lvmd.service || true
# and symlinks that might be related
sudo rm /usr/lib/systemd/system/lvmd.service || true
sudo systemctl daemon-reload
sudo systemctl reset-failed
sudo systemd-run --unit=lvmd.service ${LVMD_HOME}/bin/lvmd --config=${LVMD_HOME}/run/lvmd.yaml

}


createThinPool

# ---
# If managed, we just don't install and run LVMD on Host, we just install LVM

# buildLvmdromSrc

# installLVMD
