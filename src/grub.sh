#!/bin/sh

# Create directories and intall grub
# @param $1 basedir
# @param $2 ISO size (MB)
# @param $3 sudo/doas
create_base() {
	# Create ISO file
	mkdir $1/build
	dd	if=/dev/zero \
		of=$1/build/multiboot.iso \
		bs=1M \
		count=$2 \
		status=progress

	# Mount to loop
	LOOP=$($3 losetup -f)
	$3 losetup $LOOP $1/build/multiboot.iso

	# Partition ISO
	echo "g
	n
	1

	+100M
	t
	1
	n
	2


	w" | $3 fdisk $LOOP
	$3 mkfs.fat -F32 "$LOOP"p1
	$3 mkfs.fat -F32 "$LOOP"p2

	# Mount ISO
	mkdir $1/build/efi
	$3 mount "$LOOP"p1 $1/build/efi
	mkdir $1/build/efi/boot
	mkdir $1/build/data
	$3 mount "$LOOP"p2 $1/build/data

	# grub-install
	grub-install	--target=x86_64-efi \
					--bootloader-id=multiboot \
					--efi-directory=$1/build/efi \
					--boot-directory=$1/build/efi/boot \
					--removable
}
