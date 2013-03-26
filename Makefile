ISO_URL  := http://ftp.twaren.net/ubuntu-cd/precise/
ISO_FILE := ubuntu-12.04.2-alternate-amd64.iso
ONE_TMPL := ttylinux.tar.gz
DATE	 := $$(date +%y%m%d-%H%M)

all: iso

iso: 
	mkdir -p cd-src cd-dst cd-dst/one-templates
	if [ ! -f /usr/bin/genisoimage ]; then apt-get -y install genisoimage; fi
	if [ ! -f /usr/bin/isohybrid ]; then apt-get -y install syslinux; fi
	if [ ! -f "$(ISO_FILE)" ]; then wget $(ISO_URL)/$(ISO_FILE); fi
	if [ ! -f "$(ONE_TMPL)" ]; then wget http://dev.opennebula.org/attachments/download/170/$(ONE_TMPL) -O $(ONE_TMPL); fi
	if [ ! -f "cd-dst/one-templates/$(ONE_TMPL)" ]; then cp $(ONE_TMPL) cd-dst/one-templates/$(ONE_TMPL); fi
	mount -o loop $(ISO_FILE) cd-src/
	rsync -av cd-src/ cd-dst/
	umount cd-src
	cp isolinux/* 	cd-dst/isolinux
	cp preseed/* 	cd-dst/preseed
	sed -i "s#\%RELEASE\%#$(DATE)#" cd-dst/isolinux/isolinux.cfg
	genisoimage -r -V "cloud-interop" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o cloud-interop.iso cd-dst
	isohybrid cloud-interop.iso

clean:
	rm -rf cd-src cd-dst cloud-interop.iso

dist-clean: clean
	rm -rf $(ISO_FILE) $(ONE_TMPL)
