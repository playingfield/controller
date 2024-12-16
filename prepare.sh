#!/bin/bash
ansible-galaxy install -p roles -r roles/requirements.yml
ansible-galaxy collection install -r collections/requirements.yml
