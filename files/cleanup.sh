#!/bin/bash -x

# minimize disk usage
echo 'Clean up yum cache'
yum clean all
echo "Remove temporary files used to build box"
rm -rf /tmp/packer-provisioner-ansible-local /var/tmp/dnf-packer-*
