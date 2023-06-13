ISO_DIR=build/iso
mkdir -p $ISO_DIR
if [ ! -f $ISO_DIR/arch.iso ]; then
	wget -O $ISO_DIR/arch.iso https://mirrors.rit.edu/archlinux/iso/2023.06.01/archlinux-2023.06.01-x86_64.iso
fi
if [ ! -f $ISO_DIR/manjaro.iso ]; then
	wget -O $ISO_DIR/manjaro.iso https://download.manjaro.org/kde/22.1.3/manjaro-kde-22.1.3-230529-linux61.iso 
fi

TOTAL_SIZE=0
for ISO in $ISO_DIR/*.iso; do
	FILE_SIZE=$(stat -c%s $ISO)
	TOTAL_SIZE=$((TOTAL_SIZE + FILE_SIZE))
done

MB_SIZE=$((TOTAL_SIZE / (1024 * 1024) + 100))
if [ $((TOTAL_SIZE % (1024 * 1024))) != 0 ]; then
	MB_SIZE=$((MB_SIZE + 1))
fi

source src/iso.sh
LOOP_DEV=""
create_base build $MB_SIZE LOOP_DEV sudo
copy_data build sudo
finalize_iso build $LOOP_DEV sudo
