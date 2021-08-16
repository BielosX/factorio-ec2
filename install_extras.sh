#!/bin/bash

yum update
yum install -y amazon-linux-extras
amazon-linux-extras enable epel
yum clean metadata
yum install -y epel-release
yum install -y inotify-tools