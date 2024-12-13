#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR=/root
echo "$PACKER_BUILDER_TYPE"
case "$PACKER_BUILDER_TYPE" in

    virtualbox-iso)
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

    ## https://access.redhat.com/site/solutions/58625 (subscription required)
    # add 'single-request-reopen' so it is included when /etc/resolv.conf is generated
    echo 'RES_OPTIONS="single-request-reopen"' >> /etc/sysconfig/network
    service network restart
    echo 'Slow DNS fix applied (single-request-reopen)'

  ;;

vmware-iso|vmware-vmx)
    yum install -y perl fuse-utils
    mkdir -p /tmp/vmware
    mkdir -p /tmp/vmware-archive
    mount -o loop $HOME_DIR/linux.iso /tmp/vmware
    tar xzf /tmp/vmware/VMwareTools-*.tar.gz -C /tmp/vmware-archive
    /tmp/vmware-archive/vmware-tools-distrib/vmware-install.pl --default
    umount /tmp/vmware;
    rm -rf  /tmp/vmware;
    rm -rf  /tmp/vmware-archive;
    rm -f $HOME_DIR/*.iso;
  ;;

*)
    echo "No guest additions implemented for ${PACKER_BUILDER_TYPE}"
    ;;

esac
