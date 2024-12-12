packer {
  required_version = ">= 1.7.0"
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1.1.1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1.1.4"
    }
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2.1.7"
    }
    hyperv = {
      version = "= 1.0.4"
      source  = "github.com/hashicorp/hyperv"
    }
    proxmox = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
    virtualbox = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "arm_client_id" {
  type    = string
  sensitive   = true
  default = "${env("ARM_CLIENT_ID")}"
  description = "The Active Directory service principal associated with your builder."
}

variable "arm_client_secret" {
  type    = string
  sensitive   = true
  description = "The password or secret for your service principal."
  default = "${env("ARM_CLIENT_SECRET")}"
}

variable "arm_location" {
  type    = string
  default = "${env("ARM_LOCATION")}"
  description = "https://azure.microsoft.com/en-us/global-infrastructure/geographies/"
}

variable "arm_resource_group" {
  type    = string
  default = "${env("ARM_RESOURCE_GROUP_IMAGES")}"
}

variable "arm_storage_account" {
  type    = string
  default = "${env("ARM_STORAGE_ACCOUNT_IMAGES")}"
}

variable "arm_subscription_id" {
  type    = string
  default = "${env("ARM_SUBSCRIPTION_ID")}"
}

variable "arm_tenant_id" {
  type    = string
  default = "${env("ARM_TENANT_ID")}"
  description = "https://www.packer.io/docs/builders/azure/arm"
}

variable "managed_image_resource_group_name" {
  type        = string
  description = "https://developer.hashicorp.com/packer/plugins/builders/azure/arm#managed_image_resource_group_name"
  default     = "ansiblebook"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:463fa92155b886e31627f6713e1c2824343762245a914715ffd6f2efc300b7a1"
}

variable "iso_url1" {
  type    = string
  default = "./packer_cache/AlmaLinux-8.10-x86_64-dvd.iso"
}

variable "iso_url2" {
  type    = string
  default = "https://almalinux.mirror.wearetriple.com/8/isos/x86_64/AlmaLinux-8.10-x86_64-dvd.iso"
}

variable "vagrantcloud_token" {
  type    = string
  default = "${env("VAGRANT_CLOUD_TOKEN")}"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

locals {
  version = "8.10.${local.timestamp}"
}

source "azure-arm" "controller" {
  azure_tags = {
    product = "controller"
  }
  client_id                         = "${var.arm_client_id}"
  client_secret                     = "${var.arm_client_secret}"
  plan_info {
    plan_name      = "8-gen2"
    plan_product   = "almalinux"
    plan_publisher = "almalinux"
  }
  image_offer                       = "almalinux"
  image_publisher                   = "almalinux"
  image_sku                         = "8-gen2"
  location                          = "${var.arm_location}"
  managed_image_name                = "controller"
  managed_image_resource_group_name = "${var.managed_image_resource_group_name}"
  os_disk_size_gb                   = "30"
  os_type                           = "Linux"
  subscription_id                   = "${var.arm_subscription_id}"
  tenant_id                         = "${var.arm_tenant_id}"
  vm_size                           = "Standard_D8_v3"
}

source "virtualbox-iso" "controller" {
  boot_command            = ["<tab> append initrd=initrd.img inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg noipv6<enter><wait>"]
  cpus                    = 4
  guest_additions_mode    = "upload"
  guest_additions_path    = "VBoxGuestAdditions.iso"
  guest_os_type           = "RedHat_64"
  headless                = true
  http_directory          = "kickstart"
  iso_checksum            = "${var.iso_checksum}"
  iso_urls                = ["${var.iso_url1}", "${var.iso_url2}"]
  shutdown_command        = "echo 'vagrant' | /usr/bin/sudo -S /sbin/shutdown -h 0"
  ssh_password            = "vagrant"
  ssh_username            = "root"
  ssh_wait_timeout        = "10000s"
  vboxmanage              = [["modifyvm", "{{ .Name }}", "--memory", "4096"], ["modifyvm", "{{ .Name }}", "--cpus", "4"]]
  virtualbox_version_file = ".vbox_version"
  vm_name                 = "controller"
}

source "vmware-iso" "controller" {
  boot_command        = ["<tab> append initrd=initrd.img inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg noipv6<enter><wait>"]
  boot_wait           = "10s"
  cpus                = 4
  guest_os_type       = "Centos-64"
  headless            = false
  http_directory      = "kickstart"
  iso_checksum        = "${var.iso_checksum}"
  iso_urls            = ["${var.iso_url1}", "${var.iso_url2}"]
  output_directory    = "output-vmware-iso"
  shutdown_command    = "echo 'vagrant' | sudo -S /sbin/shutdown -h 0"
  ssh_password        = "vagrant"
  ssh_username        = "root"
  ssh_wait_timeout    = "10000s"
  tools_upload_flavor = "linux"
  vm_name             = "controller"
  vmdk_name           = "controller"
}

# https://developer.hashicorp.com/packer/plugins/builders/hyperv/iso
source "hyperv-iso" "controller" {
  boot_command = [
    "c<wait>",
    "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=AlmaLinux-8-10-x86_64-dvd ro ",
    "inst.text ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>",
    "initrdefi /images/pxeboot/initrd.img<enter>",
    "boot<enter><wait>"
  ]
  boot_wait            = "5s"
  communicator         = "ssh"
  cpus                 = 2
  disk_size            = 65536
  disk_block_size      = 1
  enable_secure_boot   = true
  enable_mac_spoofing  = true
  secure_boot_template = "MicrosoftUEFICertificateAuthority"
  generation           = 2
  guest_additions_mode = "disable"
  headless             = true
  http_directory       = "kickstart"
  keep_registered      = false
  iso_checksum         = "${var.iso_checksum}"
  iso_urls             = ["${var.iso_url1}", "${var.iso_url2}"]
  mac_address          = "00c0ffeec0de"
  memory               = 4096
  shutdown_command     = "shutdown -P now"
  shutdown_timeout     = "30m"
  ssh_password         = "vagrant"
  ssh_username         = "root"
  ssh_wait_timeout     = "10000s"
  switch_name          = "Wi-Fi"
  vm_name              = "controller"
  vlan_id              = ""
}

build {
  sources = ["source.azure-arm.controller", "source.hyperv-iso.controller", "source.virtualbox-iso.controller", "source.vmware-iso.controller"]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts         = ["controller.sh"]
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"]
    inline_shebang  = "/bin/sh -x"
    only            = ["azure-arm"]
  }

  post-processors {
    post-processor "vagrant" {
      except               = ["azure-arm.controller"]
      keep_input_artifact  = true
      compression_level    = 9
      output               = "output-images/controller.x86_64.{{.Provider}}.box"
      vagrantfile_template = "Vagrantfile.template"
    }
    post-processor "shell-local" {
      keep_input_artifact = true
      inline              = ["ovftool output-images/controller.vmx output-images/controller.ova"]
      only                = ["vmware-ova"]
    }
    post-processor "vagrant-cloud" {
      access_token = "${var.cloud_token}"
      box_tag      = "ansiblebook/controller"
      only         = ["vmware-iso", "virtualbox-iso", "hyperv-iso"]
      version      = "${local.version}"
    }
  }
}
