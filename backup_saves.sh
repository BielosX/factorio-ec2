#!/bin/bash
aws --region eu-central-1 ssm send-command --document-name factorio_saves_backup --targets Key=tag:Name,Values=factorio-server