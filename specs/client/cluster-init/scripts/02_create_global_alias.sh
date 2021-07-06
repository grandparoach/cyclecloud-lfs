#!/bin/bash

if [ "${jetpack config lustre.type}" = "durable" ]; then
    exit 0
fi

# Create HSM functions to archive, restore and check hsm_state for all users (ie. /etc/bashrc)
mount_point=$(jetpack config lustre.mount_point)
if grep -qF "hsm_archive()" /etc/bashrc; then
	echo /etc/bashrc already has HSM alias defined | systemd-cat -p info
else
	cat <<EOF >>/etc/bashrc
hsm_archive() {
	find $mount_point -type f -print0 | xargs -r0 -L 50 sudo lfs hsm_archive
}
hsm_restore() {
	find $mount_point -type f -print0 | xargs -r0 -L 50 sudo lfs hsm_restore
}
hsm_state() { 
  	find $mount_point -type f -print0 | xargs -r0 -L 50 sudo lfs hsm_state | grep "$1" | wc -l
}
EOF
fi
source $HOME/.bashrc

cp $CYCLECLOUD_SPEC_PATH/files/Lustre-HSM* $mount_point
