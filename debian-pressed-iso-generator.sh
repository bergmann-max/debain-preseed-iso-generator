#!/usr/bin/env bash
# This script generates debian ISOs with preseed for multiple environments

# name of tmp dir
ISOFILEDIR="isofiles"
# filename debian netinstall iso 
NETINST="debian-*-amd64-netinst.iso"
# URL to the newst debian-*-amd64-netinst.iso
NETINSTISO="ftp://cdimage.debian.org/cdimage/release/current/amd64/iso-cd"
# URL to debian-*-amd64-netinst.iso checksum
CHECKSUM="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"


# change to the script dir
BASEDIR=$(dirname "$0")
cd "${BASEDIR}" || exit


# delet old ISO file
if [ -f "${NETINST}" ]; then
    rm --verbose "$NETINST"
fi


# downlowd the newest debian-*-amd64-netinst.iso
wget --recursive --no-host-directories --cut-dirs=5 --no-parent --accept "debian-[!mac!edu]*-amd64-netinst.iso" --reject "*update*" ${NETINSTISO} --directory-prefix="./"

# verify the checksum
if [[ -n $(head --lines=1 <(curl --silent ${CHECKSUM} 2> /dev/null) | sha256sum --check --quiet) ]]; then
    printf "\nAbort: wrong iso\n"
    exit
fi


# start a for loop for every pressed
ENVIRONMENTS=(
    INSIDE
    DMZ
)


for ENVIRONMENT in "${ENVIRONMENTS[@]}"; do


    ISOFILE="${ENVIRONMENT}-preseed-debian-netinst.iso"


    cd "${ENVIRONMENT}" || exit


    # if there is a tmp dir it gets deleted
    # sudo is needed because some of the files in the ISO tmp will not be deleted.
    if [ -d "${ISOFILEDIR}" ]; then
        sudo rm --force --recursive "${ISOFILEDIR}"
    fi


    # possible old preseed ISO gets deleted
    if [ -f "${ISOFILE}" ]; then
        rm --verbose "${ISOFILE}"
    fi


    # unzip the newest debian-*-amd64-netinst.iso into a tmp dir
    7z x  ../debian-*-amd64-netinst.iso -o"${ISOFILEDIR}"


    # Put the  preseed.cfg into initrd
    chmod +w --recursive "${ISOFILEDIR}"/install.amd/
    gunzip "${ISOFILEDIR}"/install.amd/initrd.gz
    echo preseed.cfg | cpio --format=newc --create --append --file="${ISOFILEDIR}"/install.amd/initrd
    gzip "${ISOFILEDIR}"/install.amd/initrd
    chmod -w --recursive "${ISOFILEDIR}"/install.amd/


    # make a new checksum for the preseed iso
    cd isofiles || exit
    md5sum $(find -follow -type f) > md5sum.txt
    cd .. || exit


    # make a preseed iso
    genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "${ISOFILE}" "${ISOFILEDIR}"


    # make the preseed iso bootable
    isohybrid "${ISOFILE}"


    # delet tmp dir
    # sudo is needed because some of the files in the ISO tmp will not be deleted
    if [ -d "${ISOFILEDIR}" ]; then
        sudo rm --force --recursive "${ISOFILEDIR}"
    fi


    cd ..

done
