#!/bin/sh

# Create directories and intall grub
# @param $1 builddir
# @param $2 ISO size (MB)
# @param $3 out: loop device name
# @param? $4 sudo/doas
create_base() {
	# Create ISO file
	dd	if=/dev/zero \
		of=$1/multiboot.iso \
		bs=1M \
		count=$2 \
		status=progress

	# Mount to loop
	local LOOP=$($4 losetup -f)
	$4 losetup -P $LOOP $1/multiboot.iso

	# Partition ISO
	echo "g
	n
	1

	+100M
	t
	1
	n
	2


	w" | $4 fdisk $LOOP
	$4 mkfs.fat -F32 "$LOOP"p1
	$4 mkfs.fat -F32 "$LOOP"p2

	# Mount ISO
	mkdir $1/efi
	$4 mount "$LOOP"p1 $1/efi
	$4 mkdir $1/efi/boot
	mkdir $1/data
	$4 mount "$LOOP"p2 $1/data

	# grub-install
	$4 grub-install	--target=x86_64-efi \
					--bootloader-id=multiboot \
					--efi-directory=$1/efi \
					--boot-directory=$1/efi/boot \
					--removable

	# Return loop name
	eval "$3=\$LOOP"
}

# Copy ISOs to multiboot ISO
# @param $1 builddir
# @param? $2 sudo/doas
copy_data() {
	mkdir -p $1/mnt
	for SRC in $1/iso/*.iso; do
		DEST=$1/data/$(basename $SRC .iso)
		$2 mkdir -p $DEST
		$2 mount -o ro $SRC $1/mnt
		$2 cp -r $1/mnt/* $DEST
		$2 umount $1/mnt
	done
}

# Finalize ISO
# @param $1 builddir
# @param $2 loop device
# @param? $3 sudo/doas
finalize_iso() {
	$3 umount $1/efi
	$3 umount $1/data
	$3 losetup -d $2
}
