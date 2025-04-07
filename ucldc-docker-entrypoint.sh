#!/bin/bash
set -e

# Run a python script to create config file at /etc/nuxeo/conf.d/ucldc.conf
if [[ ${NUXEO_SKIP_CONFIG} != true && ${NUXEO_SKIP_CONFIG} != 'True' ]] ; then
    if ! python3 /client_config/configure.py; then
        echo "Error running /client_config/configure.py"
        exit 1
    fi
fi

# run Nuxeo's docker entrypoint script
exec /docker-entrypoint.sh "$@"