## TODO: next release
## Note: https://help.ubuntu.com/community/Installation/MinimalCD
## Maybe use http://archive.ubuntu.com/ubuntu/dists/raring/main/installer-i386/current/images/netboot/mini.iso for next release

BASE	 := saucy
ISO_URL  := http://ftp.twaren.net/ubuntu-cd/$(BASE)
ISO_FILE := ubuntu-13.10-server-amd64.iso
DATE	 := $$(date +%y%m%d-%H%M)
VERSION	 := 0.7.0

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
	cp isolinux/* 	cd-dst/isolinux
	cp preseed/* 	cd-dst/preseed
	sed -i "s#\%RELEASE\%#$(VERSION)_$(DATE)#" cd-dst/isolinux/isolinux.cfg

bigtop: base
	genisoimage -r -V "Haduzilla $(DATE)" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o bigtop-$(VERSION)_$(BASE).iso cd-dst
	isohybrid bigtop-$(VERSION)_$(BASE).iso

iso: bigtop

clean:
	rm -rf cd-src cd-dst bigtop-$(VERSION)_$(BASE).iso

dist-clean: clean
	rm -rf $(ISO_FILE) $(ONE_TMPL)
