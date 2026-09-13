#!/bin/sh

set -eu

SERVER_DATA="/opt/cfx-server-data"

echo "=========================================="
echo " FiveM / GTA V Enhanced"
echo "=========================================="
echo ""
echo "CFX server data: ${SERVER_DATA}"
echo ""

if [ ! -d "${SERVER_DATA}/.git" ]; then
    echo "Server data not found."
    echo "Cloning:"
    echo "${SERVER_DATA_URL}"
    echo ""

    git clone \
        --depth 1 \
        --branch "${SERVER_DATA_BRANCH}" \
        "${SERVER_DATA_URL}" \
        "${SERVER_DATA}"
fi

if [ ! -f "${SERVER_DATA}/server.cfg" ]; then
    echo ""
    echo "ERROR: server.cfg not found:"
    echo "${SERVER_DATA}/server.cfg"
    echo ""
    exit 1
fi

echo "Starting Cfx Enhanced server..."
echo ""

cd "${SERVER_DATA}"

exec /opt/cfx-server/cfx-server \
    +set citizen_dir /opt/cfx-server/citizen/ \
    +exec server.cfg
