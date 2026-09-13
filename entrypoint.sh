#!/bin/sh

set -eu

SERVER_DATA="/opt/cfx-server-data"
SV_LICENSE_KEY="${SV_LICENSE_KEY:-YOUR_CFX_LICENSE_KEY}"

mkdir -p "${SERVER_DATA}"

echo "=========================================="
echo " FiveM / GTA V Enhanced"
echo "=========================================="
echo ""
echo "CFX server data: ${SERVER_DATA}"
echo ""

if [ ! -d "${SERVER_DATA}/.git" ]; then
    echo "Server data not found."
    echo "Cloning:"
    echo "${SERVER_DATA_URL:-https://github.com/citizenfx/cfx-server-data.git}"
    echo ""

    git clone \
        --depth 1 \
        --branch "${SERVER_DATA_BRANCH:-master}" \
        "${SERVER_DATA_URL:-https://github.com/citizenfx/cfx-server-data.git}" \
        "${SERVER_DATA}"
fi

if [ ! -f "${SERVER_DATA}/server.cfg" ]; then
    cat > "${SERVER_DATA}/server.cfg" <<EOF
endpoint_add_tcp "0.0.0.0:30120"
endpoint_add_udp "0.0.0.0:30120"

sv_hostname "Willem1981 Enhanced Test Server"

sets sv_projectName "Willem1981 Enhanced"
sets sv_projectDesc "FiveM GTA V Enhanced Server"

sets tags "enhanced"
sets locale "en-US"

set onesync on
sv_maxclients 48
sv_scriptHookAllowed 0
sv_licenseKey "${SV_LICENSE_KEY}"

ensure mapmanager
ensure spawnmanager
ensure basic-gamemode
EOF
fi

if [ -n "${SV_LICENSE_KEY}" ] && [ "${SV_LICENSE_KEY}" != "YOUR_CFX_LICENSE_KEY" ]; then
    sed -i "s|sv_licenseKey .*|sv_licenseKey \"${SV_LICENSE_KEY}\"|" "${SERVER_DATA}/server.cfg"
fi

echo "Starting Cfx Enhanced server..."
echo ""

cd "${SERVER_DATA}"

exec /opt/cfx-server/FXServer \
    +set citizen_dir /opt/cfx-server/citizen/ \
    +exec server.cfg
