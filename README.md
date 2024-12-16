# Ansible Controller with SemaphoreUI

This project automates the deployment of an Ansible Controller featuring a web-based interface through SemaphoreUI.

![screenshot of Semaphore](screenshot.png "SemaphoreUI")

## Contents

- [Overview](#overview)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Overview

This project provides a development environment for deploying an Ansible Controller with SemaphoreUI.
In this production-like setup, Semaphore, PostgreSQL and Nginx, run directly on the host system.
This setup can host Clusterlust - the project to create a Kubernetes cluster with Kubespray.

## Quick Start Windows/macOS/Ubuntu Laptop

### Follow these steps to set up the environment:

1. You will need a Hypervisor to create a virtual machine on your machine with **Vagrant** (discussed below).
   - [VirtualBox](https://www.virtualbox.org/), available for Windows/macOS/Linux
   - **Hyper-V** a Windows-only feature.
   - [Vagrant](https://www.vagrantup.com/) available for Windows/macOS/Linux, download and install.

2. Create a sub-directory named `controller` on your machine.
3. Copy the `Vagrantfile.template` from this repository to `Vagrantfile` in this directory.
4.
  - If on Windows start an Administrator Powershell and change directory to the directory controller.
  - In on Mac start a terminal and change directory to the directory controller.
5. Run `vagrant up` and take not of the IP address that is logged.
6. Browse with https to the IP address. (NOTE: The certificate is self-signed at first.)

## Quick Start AlmaLinux controller host

### Prerequisites**:

   **Note**: The `inventory/local` configuration is suitable for direct deployment on systems like Red Hat, AlmaLinux, Rocky Linux (8), or Ubuntu Jammy. In this setup, Vagrant and VirtualBox are not required.

### Follow these steps to set up the environment:

1. **Clone the repository**:

   ```bash
   git clone https://github.com/playingfield/controller.git
   cd controller
   ```
2. **Install Ansible in a Python virtualenv**:

   ```bash
    source ansible.sh
    ./prepare.sh
   ```

3. **Define the variables in inventory/{{ name }}/group_vars**:
   For instance, when you use the `local` inventory on an Ubuntu 22.04 machine, change this file
   `inventory/local/group_vars/database.yml` from 15 to 14:

   ```yaml
   postgres_version: 14
   ```

4. **Define these secrets as environment variables**
   Store them in a safe place afterwards:

   ```bash
   export DB_PASS=your_database_password
   export SSH_PASSPHRASE=KeyWillBeGeneratedWithAPassphrase
   ```

5. **Run the playbook**:
   Execute the Ansible playbook to provision to the default 'local' inventory:
   ```bash
   ./provision.yml --list-tags

playbook: provision.yml

  play #1 (database): Database Server	TAGS: [database,postgres]
      TASK TAGS: [database, postgres]

  play #2 (semaphore): Semaphore in Systemd	TAGS: [semaphore]
      TASK TAGS: [semaphore]

  play #3 (semaphore): Tools	TAGS: [tools]
      TASK TAGS: [tools]

  play #4 (semaphore): Configure Semaphore	TAGS: []
      TASK TAGS: [api]

  play #5 (web): Reverse Proxy	TAGS: []
      TASK TAGS: [nginx]
   ```

## Configuration

- **SSL Certificates**: By default, self-signed certificates are used. For production environments, it is recommended to implement certificates from a trusted certificate authority.

- **Database**: Ensure that the `DB_PASS` environment variable is set with a strong password before running the playbook. To disable installation of Postgres and use your own intance set `postgres_enabled: false`
  Semaphore needs to connect to the database, you can use a non-default IP address based on an interface like:

```yaml
    semaphore_db_host: "{{ ansible_enp0s8.ipv4.address }}"
```

- **Software Environments**: This project contains three inventories, but can be run with inventories define in external repositories modeled after the examples.

This is the important part of the 'local' configuration:

```yaml
controller:
   ansible_connection: local
   ansible_host: localhost
   database:
      postgres:
         enabled: true
         name: postgres
         owner: postgres
         password: '{{ lookup(''env'', ''DB_PASS'') }}'
         username: postgres
      semaphore:
         enabled: true
         name: semaphore
         owner: semaphore
         password: '{{ lookup(''env'', ''DB_PASS'') }}'
         username: semaphore
   docker_install_compose: true
   docker_install_compose_plugin: true
   nginx_add_repo: false
   postgres_enabled: true
   postgres_listen_addresses: 127.0.0.1
   postgres_version: 15
   semaphore_web_root: https://20.224.75.82
   server_name: '{{ lookup(''env'', ''HOSTNAME'') }}'
   ssh_passphrase: '{{ lookup(''env'', ''SSH_PASS'') }}'
   terraform_ver: 1.8.2
   use_docker: true
   use_opentofu: false
   use_powershell: true
   use_terraform: true
```

## Usage

After successful installation, SemaphoreUI is accessible via your web browser at the address configured.
You can find the credentials to login with:

```bash
sudo grep ADMIN /home/semaphore/.env
```

To remove Semaphore run:
```bash
./provision.yml --tags semaphore -e desired_state=absent
```

To reinstall Semaphore run with the default `desired_state`, i.e. _present_:
```bash
./provision.yml --tags semaphore
```

## Contributing

Contributions are welcome! Feel free to submit pull requests or open issues for suggestions and improvements.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.
