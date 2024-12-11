#!/bin/bash -eux
export DB_PASS=your_database_password
export SSH_PASSPHRASE=KeyWillBeGeneratedWithAPassphrase

# When this is a RHEL8 variant
if [ -e /etc/redhat-release ]; then
   major=$(tr -dc '0-9.' <  /etc/redhat-release | cut -d \. -f1)
   if ((major == 8))
   then
     # Update the GPG keys before any other dnf/yum task
     sudo rpm --import https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux
     sudo dnf upgrade almalinux-release -y
     sudo dnf makecache
     # ansible-core installs python3.x and git-core
     sudo dnf install -y ansible-core
     # For platform-python for remote use.
     sudo dnf install -y python3-jmespath python3-requests
     # Install Python tools
     sudo dnf install -y python3.12-pip python3.12-devel gcc
   fi
fi
# /etc/alternatives/pip3 will point to 3.6, ansible uses 3.12
sudo pip3.12 install jmespath
ansible --version
(git clone https://github.com/playingfield/controller.git)
cd controller && source ansible.sh && ./prepare.sh
echo $DB_PASS $SSH_PASSPHRASE
./provision.yml -i inventory/local/hosts -v
