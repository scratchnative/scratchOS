#!/bin/sh

path="$(dirname $0)/../"
mkdir -p tmp

cp $path/limine/limine.sys ./tmp/
cp $path/limine/*.bin ./tmp
cp $path/limine.cfg ./tmp
cp $path/build/kernel.elf ./tmp/kernel.elf

xorriso -as mkisofs -b limine-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		--efi-boot limine-cd-efi.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		./tmp -o scratchOS.iso
	$path/limine/limine-deploy scratchOS.iso
rm -rf ./tmp
