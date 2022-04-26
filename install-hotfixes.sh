#!/bin/bash
set -e

usage() {
  exec >&2
  echo "Usage:"
  echo "  install-hotfixes.sh [--clid <clid>] [--connect-url <connecturl>]"
  exit 2
}

echo '===================='
echo '- Install hotfixes -'
echo '===================='

if [[ -f $NUXEO_HOME/configured ]]; then
  echo "Nuxeo is already configured."
  echo "This script must be used in a Dockerfile to install hotfixes at build time."
  exit 2
fi

# default arguments for mp-hotfix command
mpHotfixArgs="--accept yes"

while [ $# -ne 0 ]; do
  case $1 in
    --clid) clid=$2; shift 2 ;;
    --connect-url) connect_url=$2; shift 2 ;;
    -*) echo "Unknown option: $1" >&2; usage ;;
  esac
done

echo
if [ -n "$clid" ]; then
  echo "Setting CLID"
  # Replace -- by a carriage return
  clid="${clid//--/\\n}"
  mkdir -p $NUXEO_HOME/nxserver/data/
  printf "%b\n" "$clid" >> $NUXEO_HOME/nxserver/data/instance.clid
fi

if [ -n "$connect_url" ]; then
  echo "Setting Connect URL: $connect_url"
  printf "org.nuxeo.connect.url=%b\n" "$connect_url" >> $NUXEO_HOME/bin/nuxeo.conf
fi

echo
NUXEO_CONF=$NUXEO_HOME/bin/nuxeo.conf $NUXEO_HOME/bin/nuxeoctl mp-hotfix $mpHotfixArgs

echo
if [ -n "$clid" ]; then
  echo "Unsetting CLID"
  rm -rf $NUXEO_HOME/nxserver/data/
fi

if [ -n "$connect_url" ]; then
  echo "Unsetting Connect URL"
  sed -i "/org.nuxeo.connect.url=/d" $NUXEO_HOME/bin/nuxeo.conf
fi

# Set appropriate permissions on distribution directory
chmod -R g+rwX $NUXEO_HOME