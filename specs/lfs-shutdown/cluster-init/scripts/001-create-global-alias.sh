#!/bin/bash

# Create HSM functions to archive, restore and check hsm_state for all users (ie. /etc/bashrc)
if grep -qF 'hsm_archive()' /etc/bashrc; then
	echo /etc/bashrc already has HSM alias defined | systemd-cat -p info
else
	cat <<EOF >>/etc/bashrc
hsm_archive() {
	find $(jetpack config lustre.mount_point) -type f -print0 | xargs -r0 -L 50 sudo lfs hsm_archive
}
hsm_restore() {
	find $(jetpack config lustre.mount_point) -type f -print0 | xargs -r0 -L 50 sudo lfs hsm_restore
}
hsm_state() { 
  	find $(jetpack config lustre.mount_point) -type f -print0 | xargs -r0 -L 50 sudo lfs hsm_state | grep "$1" | wc -l
}
EOF
fi
source /etc/bashrc

cp $CYCLECLOUD_SPEC_PATH/files/Lustre-HSM* /lustre
