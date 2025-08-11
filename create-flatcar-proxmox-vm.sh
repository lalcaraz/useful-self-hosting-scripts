#!/bin/bash

if [[ -n "$1" ]]; then
	VM_ID=$1
else
	read -t 10 -p "Enter the VM number you wanna use for this new instance: " VM_ID
fi

if [[ -n "$2" ]]; then
	STORAGE_ID=$2
else
	read -t 10 -p "Enter the storage ID you wanna use for this new instance: " STORAGE_ID
fi

if [[ -n "$VM_ID" && -n "$STORAGE_ID" ]]; then
        # Get Stable image
        wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_proxmoxve_image.img

        # create the vm and import the image to its disk
        qm create $VM_ID --cores 2 --memory 4096 --net0 "virtio,bridge=vmbr0" --ipconfig0 "ip=dhcp"
        qm disk import $VM_ID flatcar_production_proxmoxve_image.img $STORAGE_ID

        # tell the vm to boot from the imported image
        qm set $VM_ID --scsi0 $STORAGE_ID:vm-$VM_ID-disk-0
        qm set $VM_ID --boot order=scsi0

        # Create the cloud-init CD-ROM drive which activates the cloud-init options for the VM.
        # This is required for using ignition config as well.
        qm set $VM_ID --ide2 $STORAGE_ID:cloudinit

        # Remove image after usage
        rm flatcar_production_proxmoxve_image.img
else
	echo ""
        if [[ -z "$VM_ID" ]]; then
                echo "Error: VM ID is required as the first argument or via prompt."
        fi
        if [[ -z "$STORAGE_ID" ]]; then
                echo "Error: Storage ID is required as the second argument or via prompt."
        fi
        exit 1
fi
