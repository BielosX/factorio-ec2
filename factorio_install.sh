#!/bin/bash
VERSION=$1
if [ -z "$VERSION" ]; then
    VERSION="stable"
fi
FACTORIO_LINK=$(printf "https://factorio.com/get-download/%s/headless/linux64" $VERSION)
echo $FACTORIO_LINK
wget -nv -O server.tar.xz $FACTORIO_LINK
tar -xf server.tar.xz
mkdir -p /opt/factorio
cp -r factorio/* /opt/factorio
adduser factorio --user-group
chown -R factorio:factorio /opt/factorio
chmod -R g+rwx /opt/factorio
mkdir -p /var/lib/factorio
chown -R factorio:factorio /var/lib/factorio
chmod -R g+rwx /var/lib/factorio
mkdir -p /etc/factorio
chown -R factorio:factorio /etc/factorio
chmod -R g+rwx /etc/factorio
systemctl enable factorio.service
systemctl enable backup-on-change.service