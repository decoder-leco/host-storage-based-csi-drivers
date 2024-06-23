#!/bin/bash
# set -uxo pipefail
set -o errexit
# --- why [set -uxo pipefail] and not [set -o errexit] ?
# 

figlet 'TOPOLVM DISL LVM SETUP'

ls -alh  ~/.topolvm.disk.lvm.setup.env.sh

source ~/.topolvm.disk.lvm.setup.env.sh || true

export TOPOLVM_DISK_DEVICE_NAME=$(cat ~/.topolvm.disk.lvm.setup.env.sh | grep 'TOPOLVM_DISK_DEVICE_NAME' | awk -F '=' '{ print $NF }' | sed 's#"##g')
export TOPOLVM_VOL_GRP_NAME=$(cat ~/.topolvm.disk.lvm.setup.env.sh | grep 'TOPOLVM_VOL_GRP_NAME' | awk -F '=' '{ print $NF }' | sed 's#"##g')

echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> TOPOLVM DISK LVM SETUP - TOPOLVM_DISK_DEVICE_NAME=[${TOPOLVM_DISK_DEVICE_NAME}]"
echo "### >>> TOPOLVM DISK LVM SETUP - TOPOLVM_VOL_GRP_NAME=[${TOPOLVM_VOL_GRP_NAME}]"
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "
echo "### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> ### >>> "

if [ "x${TOPOLVM_DISK_DEVICE_NAME}" == "x" ]; then
  echo "ERROR! The 'TOPOLVM_DISK_DEVICE_NAME' env. var. must be set, but is not!"
  exit 7
fi;

if [ "x${TOPOLVM_VOL_GRP_NAME}" == "x" ]; then
  echo "ERROR! The 'TOPOLVM_VOL_GRP_NAME' env. var. must be set, but is not!"
  exit 11
fi;







teardownLvmNonFormattedDiskSetup() {

figlet "teardown LVM setup"

# export DEVICE_NAME="/dev/$(basename $(readlink /dev/disk/by-id/google-${DISK_NAME}))"

echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> TOPOLVM_DISK_DEVICE_NAME=[${TOPOLVM_DISK_DEVICE_NAME}]"
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "

# Creating physical volumes
echo ">> List Linux Disk Devices, with their sizes and filesystem:"

sudo lsblk -o name,size,fstype

echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> # Remove LVM Physical Volumes from volume group: "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
vgreduce ${TOPOLVM_VOL_GRP_NAME} ${TOPOLVM_DISK_DEVICE_NAME} || true
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> # Remove LVM Physical Volumes: "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "

# sudo pvcreate ${TOPOLVM_DISK_DEVICE_NAME}
sudo pvremove ${TOPOLVM_DISK_DEVICE_NAME} || true

echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> # Remove LVM Volume Group: "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "

sudo vgremove ${TOPOLVM_VOL_GRP_NAME}

echo ">> List LVM Physical Volumes:"

sudo pvscan
sudo pvdisplay
sudo pvs


echo ">> List LVM Volume Groups:"

sudo vgscan
sudo vgdisplay
sudo vgs


}





lvmNonFormattedDiskSetup() {

figlet "LVM setup"

sudo apt-get install -y lvm2

# export DEVICE_NAME="/dev/$(basename $(readlink /dev/disk/by-id/google-${DISK_NAME}))"

echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> TOPOLVM_DISK_DEVICE_NAME=[${TOPOLVM_DISK_DEVICE_NAME}]"
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "

# Creating physical volumes
echo ">> List Linux Disk Devices, with their sizes and filesystem:"

sudo lsblk -o name,size,fstype

echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> # Create LVM Physical Volumes: "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "

sudo pvcreate ${TOPOLVM_DISK_DEVICE_NAME}
# sudo pvremove ${TOPOLVM_DISK_DEVICE_NAME}


echo ">> List LVM Physical Volumes:"

sudo pvscan
sudo pvdisplay
sudo pvs

echo ">>> >>>"
echo "Note that the LVM Physical Vol. created from the raw disk device [${TOPOLVM_DISK_DEVICE_NAME}] has same name than the device"
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "

echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> # Create LVM Volume Groups "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
# Create LVM Volume Groups

sudo vgcreate ${TOPOLVM_VOL_GRP_NAME} ${TOPOLVM_DISK_DEVICE_NAME}

echo ">> List LVM Volume Groups:"

sudo vgscan
sudo vgdisplay
sudo vgs

# Listing the physical volumes attached to a volume group
echo ">> Listing the physical volumes attached to the [${TOPOLVM_VOL_GRP_NAME}] LVM Volume Group"

sudo pvdisplay -S vgname="${TOPOLVM_VOL_GRP_NAME}" -C -o pv_name

# with more infos.:
sudo pvdisplay -S vgname="${TOPOLVM_VOL_GRP_NAME}" -C


# counting the number of Physical Volumes for a given volume group:
sudo pvdisplay -S vgname="${TOPOLVM_VOL_GRP_NAME}" -C -o pv_count

sudo pvdisplay -S vgname="${TOPOLVM_VOL_GRP_NAME}" -C -o pv_name,pv_count

# To add more Physical Volumes to a given Volume Group:
# vgextend ${TOPOLVM_VOL_GRP_NAME} <physical_volume1> <physical_volume2> 

echo ">>> >>>"
echo "Note: to add more LVM Physical Volumes to the [${TOPOLVM_VOL_GRP_NAME}] LVM Volume Group, run:"
echo "  vgextend ${TOPOLVM_VOL_GRP_NAME} <physical_volume1> <physical_volume2>"
echo ">>> >>>"
echo "Note: to remove LVM Physical Volumes from the [${TOPOLVM_VOL_GRP_NAME}] LVM Volume Group, run:"
echo "  vgreduce ${TOPOLVM_VOL_GRP_NAME} <physical_volume1> <physical_volume2>"
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "


}

teardownLvmNonFormattedDiskSetup

lvmNonFormattedDiskSetup










































exit 0

lvmNonFormattedDiskExamples() {

figlet "LVM setup"

sudo apt-get install -y lvm2

export TOPOLVM_DISK_DEVICE_NAME="/dev/$(basename $(readlink /dev/disk/by-id/google-${DISK_NAME}))"

echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> TOPOLVM_DISK_DEVICE_NAME=[${TOPOLVM_DISK_DEVICE_NAME}]"
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "

# Creating physical volumes
echo ">> List Linux Disk Devices, with their sizes and filesystem:"

sudo lsblk -o name,size,fstype

echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> # Create LVM Physical Volumes: "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "

sudo pvcreate ${TOPOLVM_DISK_DEVICE_NAME}
# sudo pvremove ${TOPOLVM_DISK_DEVICE_NAME}


echo ">> List LVM Physical Volumes:"

sudo pvscan
sudo pvdisplay
sudo pvs

echo ">>> >>>"
echo "Note that the LVM Physical Vol. created from the raw disk device [${TOPOLVM_DISK_DEVICE_NAME}] has same name than the device"
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "

echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> # Create LVM Volume Groups "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
# Create LVM Volume Groups
# export TOPOLVM_VOL_GRP_NAME="${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}m_vg"


sudo vgcreate ${TOPOLVM_VOL_GRP_NAME} ${TOPOLVM_DISK_DEVICE_NAME}

echo ">> List LVM Volume Groups:"

sudo vgscan
sudo vgdisplay
sudo vgs

# Listing the physical volumes attached to a volume group
echo ">> Listing the physical volumes attached to the [${TOPOLVM_VOL_GRP_NAME}] LVM Volume Group"

sudo pvdisplay -S vgname="${TOPOLVM_VOL_GRP_NAME}" -C -o pv_name

# with more infos.:
sudo pvdisplay -S vgname="${TOPOLVM_VOL_GRP_NAME}" -C


# counting the number of Physical Volumes for a given volume group:
sudo pvdisplay -S vgname="${TOPOLVM_VOL_GRP_NAME}" -C -o pv_count

sudo pvdisplay -S vgname="${TOPOLVM_VOL_GRP_NAME}" -C -o pv_name,pv_count

# To add more Physical Volumes to a given Volume Group:
# vgextend ${TOPOLVM_VOL_GRP_NAME} <physical_volume1> <physical_volume2> 

echo ">>> >>>"
echo "Note: to add more LVM Physical Volumes to the [${TOPOLVM_VOL_GRP_NAME}] LVM Volume Group, run:"
echo "  vgextend ${TOPOLVM_VOL_GRP_NAME} <physical_volume1> <physical_volume2>"
echo ">>> >>>"
echo "Note: to remove LVM Physical Volumes from the [${TOPOLVM_VOL_GRP_NAME}] LVM Volume Group, run:"
echo "  vgreduce ${TOPOLVM_VOL_GRP_NAME} <physical_volume1> <physical_volume2>"
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "

echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "
echo ">>> >>> # Create LVM Logical Volumes: "
echo ">>> >>> >>> >>> >>> >>> >>> >>> >>> >>> "

# ->
# A logical volume is like a partition, but
# instead of sitting on top of a raw disk, it
# sits on top of a volume group. You can:
# - Format a logical volume with whichever filesystem you want.
# - Mount it anywhere in the filesystem you want.
# 
# The standard operations on LVM Volumes are:
# 
# - How to create logical volumes.
# - Common operations on a logical volume.
# - Resizing a logical volume.
# - Removing a logical volume.

# + Create a logical volume:
# sudo lvcreate -L <size> -n <lvname> <vgname>

# ->> The Rook-Ceph CSI Driver will use LVM Logical Volumes that are not formatted, cf. https://rook.io/docs/rook/latest-release/Getting-Started/Prerequisites/prerequisites/#ceph-prerequisites
# I know the disk size is 60 GB, so i will create 4 LVM Logical Volumes of (15GB - 1GB) each

sudo lvcreate -L 14GB -n ${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}1 ${TOPOLVM_VOL_GRP_NAME}
sudo lvcreate -L 14GB -n ${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}2 ${TOPOLVM_VOL_GRP_NAME}
sudo lvcreate -L 14GB -n ${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}3 ${TOPOLVM_VOL_GRP_NAME}
sudo lvcreate -L 14GB -n ${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}4 ${TOPOLVM_VOL_GRP_NAME}

# Once created you can find the logical volume (as devices?) in /dev/<vgname>/<lvname> path

sudo ls -alh /dev/${TOPOLVM_VOL_GRP_NAME}/${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}1
sudo ls -alh /dev/${TOPOLVM_VOL_GRP_NAME}/${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}2
sudo ls -alh /dev/${TOPOLVM_VOL_GRP_NAME}/${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}3
sudo ls -alh /dev/${TOPOLVM_VOL_GRP_NAME}/${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}4

# I have then tested that i can get the device inside a docker container like this:

# $ docker run --name jbltest --device=/dev/${TOPOLVM_VOL_GRP_NAME}/${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}1 --restart unless-stopped -itd debian /bin/bash
# b8d63245efcf616863c6b7b66c24f6a7a41eddaad219270cf12d1d450117aa89
# $ docker exec -it jbltest /bin/bash -c "ls -alh /dev/${TOPOLVM_VOL_GRP_NAME}/${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}1"
# brw-rw---- 1 root disk 254, 0 May 31 15:22 /dev/lvm_jbl_vg1/${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}1
# $ docker exec -it jbltest /bin/bash -c "df -h /dev/${TOPOLVM_VOL_GRP_NAME}/${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}1"
# Filesystem      Size  Used Avail Use% Mounted on
# tmpfs            64M     0   64M   0% /dev

# ---
# Another interesting thing I saw:
# - 
# $ docker run --name jbltest -v /dev/${TOPOLVM_VOL_GRP_NAME}/${ROOK_CSI_LVM_LOGICAL_VOLUME_NAMING_PREFIX}1:/voyons/voir/data --restart unless-stopped -itd debian /bin/bash
# 43eee4de3c2c52e882d9837b0b100e9ea70db1f70466ccd88f60b4cbc1e0d927
# $ docker exec -it jbltest /bin/bash -c "ls -alh /voyons/voir/data"
# brw-rw---- 1 root disk 254, 0 May 31 14:14 /voyons/voir/data
# $ docker exec -it jbltest /bin/bash -c "df -h /voyons/voir/data"
# Filesystem      Size  Used Avail Use% Mounted on
# udev            3.9G     0  3.9G   0% /voyons/voir/data
# $ docker exec -it jbltest /bin/bash -c "df -h /"
# Filesystem      Size  Used Avail Use% Mounted on
# overlay         124G  3.1G  114G   3% /

}

