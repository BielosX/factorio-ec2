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
systemctl enable factorio.service