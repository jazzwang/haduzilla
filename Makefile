ISO_URL  := http://ftp.twaren.net/ubuntu-cd/precise
ISO_FILE := ubuntu-12.04.2-alternate-amd64.iso
DATE	 := $$(date +%y%m%d-%H%M)
VERSION	 := 0.5.0

all: iso

iso: 
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
	sed -i "s#\%RELEASE\%#$(DATE)#" cd-dst/isolinux/isolinux.cfg
	genisoimage -r -V "Haduzilla $(DATE)" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o bigtop-$(VERSION).iso cd-dst
	isohybrid bigtop-$(VERSION).iso

clean:
	rm -rf cd-src cd-dst bigtop-$(VERSION).iso

dist-clean: clean
	rm -rf $(ISO_FILE) $(ONE_TMPL)
