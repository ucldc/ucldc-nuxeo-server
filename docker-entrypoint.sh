#!/bin/bash
set -e

# run a python script to create config file at /etc/nuxeo/nuxeo.conf
python3 /client_config/configure.py

# run Nuxeo's docker entrypoint script
exec /docker-entrypoint.sh "$@"