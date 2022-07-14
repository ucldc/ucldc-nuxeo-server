#!/bin/bash
#echo "$@" >> /tmp/dockeroverride_params
python3 /usr/local/bin/override_scripts/docker_override.py "$@"
