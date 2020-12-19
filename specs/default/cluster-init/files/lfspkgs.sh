#!/bin/bash

# Install the Lustre-patched kernel packages
yum --nogpgcheck --disablerepo=base,extras,updates \
--enablerepo=lustreserver install \
kernel \
kernel-devel \
kernel-headers \
kernel-tools \
kernel-tools-libs \
kernel-tools-libs-devel

yum -y install lustre kmod-lustre-osd-ldiskfs lustre-osd-ldiskfs-mount lustre-resource-agents e2fsprogs lustre-tests

sed -i 's/ResourceDisk\.Format=y/ResourceDisk.Format=n/g' /etc/waagent.conf

systemctl restart waagent

weak-modules --add-kernel --no-initramfs

umount /mnt/resource
