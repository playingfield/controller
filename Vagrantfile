# -*- mode: ruby -*-
# vi: set ft=ruby :
# To use these virtual machines install Vagrant and VirtualBox.
# vagrant up

Vagrant.require_version ">= 2.0.0"

# Define environment variables DB_PASS and SSH_PASSPHRASE for your security
$DbPass = ENV['DB_PASS'] || "your_database_password"
$SshPassphrase = ENV['SSH_PASSPHRASE'] || "KeyWillBeGeneratedWithAPassphrase"

# Select the config file from the STAGE environment variable (dev or local)
# VM Configs are loaded from json files.
$Stage = ENV['STAGE'] || "dev"

# Require JSON module
require 'json'
# Read JSON file with config details
guests = JSON.parse(File.read(File.join(File.dirname(__FILE__), "inventory", $Stage, $Stage + ".json")))
# Local PATH_SRC for mounting
$PathSrc = ENV['PATH_SRC'] || "."
Vagrant.configure(2) do |config|

  # check for updates of the base image
  config.vm.box_check_update = true
  # wait a while longer
  config.vm.boot_timeout = 1200

  # update guest additions if needed
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = true
  end

  # enable ssh agent forwarding
  config.ssh.forward_agent = true

  # use the standard vagrant ssh key
  config.ssh.insert_key = false

  # Iterate through entries in JSON file
  guests.each do |guest|
    config.vm.define guest['name'], autostart: guest['autostart'] do |srv|
      srv.vm.box = guest['box']
      srv.vm.hostname = guest['name']
      # Hyper-V needs an _external_ network adapter, bound to a connected interface.
      # srv.vm.network "public_network", type: "dhcp", bridge: "Wi-Fi"
      # Better Hypervisors allow setting the IP
      srv.vm.network 'private_network', ip: guest['ip_addr']
      #srv.vm.network :forwarded_port, host: guest['forwarded_port'], guest: guest['app_port']

      # set no_share to false to enable file sharing
      srv.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: guest['no_share']
      srv.vm.provider "hyperv" do |hyperv|
        hyperv.cpus = guest['cpu']
        hyperv.memory = guest['memory']
        hyperv.vmname = guest['name']
        hyperv.enable_virtualization_extensions = true
        hyperv.vm_integration_services = {
          guest_service_interface: true,
          heartbeat: true,
          shutdown: true,
          time_synchronization: true,
        }
        hyperv.linked_clone = true
      end
      srv.vm.provider :vmware_desktop do |vmware|
        vmware.gui = guest['gui']
        vmware.vmx['memsize'] = guest['memory']
        vmware.vmx['numvcpus'] =  guest['cpus']
        vmware.vmx["ethernet0.pcislotnumber"] = "160"
        vmware.vmx["ethernet1.pcislotnumber"] = "192"
      end
      srv.vm.provider :virtualbox do |virtualbox|
        virtualbox.customize ["modifyvm", :id,
           "--audio-driver", "none",
           "--cableconnected1", "on",
           "--cpus", guest['cpus'],
           "--memory", guest['memory'],
	         "--natnet1", "192.168.33.0/24",
           "--graphicscontroller", "VMSVGA",
           "--vram", "64"
        ]
        virtualbox.gui = guest['gui']
        virtualbox.name = guest['name']
      end
    end
  end
  # install ansible+controller in the VM
  config.vm.provision "shell", privileged: false, path: "controller.sh", env: {"DB_PASS"=>$DbPass, "SSH_PASS"=>$SshPassphrase}
end
