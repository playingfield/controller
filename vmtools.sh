#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR=/root

if [ -f "$HOME_DIR/VBoxGuestAdditions.iso" ]
then
    yum install -y bzip2 tar gcc make perl cpp libstdc++-devel kernel-devel kernel-headers

    mkdir -p /tmp/vbox /run/vboxadd
    chown vboxadd /run/vboxadd
    chmod 700 /run/vboxadd
    mount -o loop $HOME_DIR/VBoxGuestAdditions.iso /tmp/vbox;
    sh /tmp/vbox/VBoxLinuxAdditions.run \
        || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
            "For more read https://www.virtualbox.org/ticket/12479";
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f $HOME_DIR/*.iso;

    yum -y erase gcc make perl cpp libstdc++-devel kernel-devel kernel-headers
    yum -y clean all

fi
