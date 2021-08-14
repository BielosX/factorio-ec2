#!/bin/bash

REGION=$1
if [ -z "$REGION" ]; then
  REGION="eu-central-1"
fi
CW_AGENT=$(printf "https://s3.%s.amazonaws.com/amazoncloudwatch-agent-%s/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm" $REGION $REGION)
SSM_AGENT=$(printf "https://s3.%s.amazonaws.com/amazon-ssm-%s/latest/linux_amd64/amazon-ssm-agent.rpm" $REGION $REGION)
yum update
yum install -y "$SSM_AGENT"
wget -nv "$CW_AGENT"
rpm -U ./amazon-cloudwatch-agent.rpm
wget -nv -O "awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
unzip awscliv2.zip
./aws/install