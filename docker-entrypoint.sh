#!/bin/bash
set -e

# run a python script to create config file at /etc/nuxeo/nuxeo.conf

# run Nuxeo's docker entrypoint script
#exec /docker-entrypoint.sh nuxeoctl console
exec /docker-entrypoint.sh "$@"
