#!/bin/bash
wget -O server.tar.xz https://factorio.com/get-download/stable/headless/linux64
tar -xf server.tar.xz
mkdir -p /opt/factorio
cp -r factorio/* /opt/factorio
systemctl enable factorio.service