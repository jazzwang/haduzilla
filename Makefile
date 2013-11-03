## TODO: next release
## Note: https://help.ubuntu.com/community/Installation/MinimalCD
## Maybe use http://archive.ubuntu.com/ubuntu/dists/raring/main/installer-i386/current/images/netboot/mini.iso for next release

ISO_URL  := http://ftp.twaren.net/debian-cd/current/amd64/iso-cd/
ISO_FILE := debian-7.2.0-amd64-netinst.iso
DATE	 := $$(date +%y%m%d-%H%M)
VERSION	 := 0.6.0

all: iso

base: 
	mkdir -p cd-src cd-dst
	if [ ! -f /usr/bin/rsync ]; then apt-get -y install rsync; fi
	if [ ! -f /usr/bin/genisoimage ]; then apt-get -y install genisoimage; fi
	if [ ! -f /usr/bin/isohybrid ]; then apt-get -y install syslinux; fi
	if [ ! -f "$(ISO_FILE)" ]; then wget $(ISO_URL)/$(ISO_FILE); fi
	mount -o loop $(ISO_FILE) cd-src/
	rsync -av cd-src/ cd-dst/
	umount cd-src
stage1: base
	mkdir -p cd-dst/preseed
	cp isolinux/* 	cd-dst/isolinux
	cp preseed/* 	cd-dst/preseed
	sed -i "s#\%RELEASE\%#$(DATE)#" cd-dst/isolinux/isolinux.cfg

bigtop: stage1
	genisoimage -r -V "Haduzilla $(DATE)" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o bigtop-$(VERSION).iso cd-dst
	isohybrid bigtop-$(VERSION).iso

iso: bigtop

clean:
	rm -rf cd-src cd-dst bigtop-$(VERSION).iso

dist-clean: clean
	rm -rf $(ISO_FILE) $(ONE_TMPL)
