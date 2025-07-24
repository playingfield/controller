# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Ansible-based project that automates the deployment of an Ansible Controller with SemaphoreUI web interface. The project deploys SemaphoreUI, PostgreSQL, and Nginx in a production-like setup for managing Ansible automation workflows.

## Core Commands

### Environment Setup
```bash
# Set up Python virtual environment and install Ansible dependencies
source ansible.sh

# Install Ansible roles and collections
./prepare.sh
```

### Required Environment Variables
Before running the playbook, set these environment variables:
```bash
export DB_PASS=your_database_password  # Must be >8 characters
export SSH_PASS=KeyWillBeGeneratedWithAPassphrase  # Must be >8 characters
```

### Main Deployment Command
```bash
# Deploy full stack (database, semaphore, nginx, tools)
./provision.yml

# Deploy specific components
./provision.yml --tags postgres,database
./provision.yml --tags semaphore
./provision.yml --tags nginx
./provision.yml --tags tools
./provision.yml --tags api

# List all available tags
./provision.yml --list-tags

# Remove Semaphore
./provision.yml --tags semaphore -e desired_state=absent
```

### Testing and Verification
```bash
# Run with verbose output and debug mode
./provision.yml -v -e debug=true

# Run ansible-lint on playbooks
ansible-lint provision.yml

# Check Semaphore credentials
sudo grep ADMIN /home/semaphore/.env
```

## Architecture

### Inventory Structure
- **inventory/local/**: For localhost deployment (AlmaLinux/Rocky/Ubuntu)
- **inventory/dev/**: Development environment configuration
- **inventory/test/**: Test environment configuration

### Ansible Roles Structure
- **Custom roles**: `semaphore/`, `api/`, `bbaassssiiee.*` (nginx_ssl, postgres_ssl, proxy, kubeblocks)
- **Third-party roles**: `andrewrothstein.*` (for tools like kubectl, helm, terraform, k9s)
- **Community roles**: `geerlingguy.docker`

### Key Components
1. **Database layer**: PostgreSQL with SSL configuration
2. **Application layer**: SemaphoreUI running as systemd service
3. **Web layer**: Nginx reverse proxy with SSL
4. **Tools layer**: Optional DevOps tools (kubectl, helm, terraform, k9s, powershell)
5. **API configuration**: Automated Semaphore setup via REST API

### Variable Hierarchy
- `inventory/{env}/group_vars/all.yml`: Global environment settings
- `inventory/{env}/group_vars/semaphore.yml`: Semaphore-specific configuration
- `inventory/{env}/group_vars/database.yml`: Database configuration
- `roles/*/defaults/main.yml`: Role default variables
- `roles/*/vars/main.yml`: Role variables

### Host Groups
- **database**: PostgreSQL installation target
- **semaphore**: SemaphoreUI and tools installation target  
- **web**: Nginx reverse proxy target
- **proxy**: Optional forward proxy (Squid) target

## Configuration Notes

### PostgreSQL Version
Check `inventory/{env}/group_vars/database.yml` for correct PostgreSQL version:
- Ubuntu 22.04: `postgres_version: 14`
- AlmaLinux 8/9: `postgres_version: 15`

### Tool Selection
Control which tools to install via `inventory/{env}/group_vars/semaphore.yml`:
- `use_docker: true/false`
- `use_helm: true/false`
- `use_k9s: true/false`
- `use_terraform: true/false`
- `use_opentofu: true/false`
- `use_powershell: true/false`

### SSL Configuration
- Self-signed certificates are used by default
- For production, replace with trusted CA certificates
- Nginx configuration in `roles/bbaassssiiee.nginx_ssl/`

## Development Workflow

1. Modify inventory variables in `inventory/{env}/group_vars/`
2. Test changes with specific tags: `./provision.yml --tags {component}`
3. Use debug mode for troubleshooting: `./provision.yml -v -e debug=true`
4. Verify installation by accessing SemaphoreUI web interface
5. Check service status: `systemctl status semaphore`

## Vagrant Integration

For development with VirtualBox/VMware/Hyper-V:
- Use `Vagrantfile.template` as starting point
- `controller.sh` script handles VM provisioning
- Default inventory: `inventory/local/hosts`