#!/bin/bash

REGION=$2
if [ -z "$REGION" ]; then
    REGION="eu-central-1"
fi
FACTORIO_VERSION="1.1.53"
BACKEND_STACK="terraform-backend"
export AWS_DEFAULT_REGION=$REGION

deploy_infra() {
  aws cloudformation deploy --template-file infra/terraform_backend.yaml --stack-name "$BACKEND_STACK"
  pushd "infra/env/bielosx-$REGION" || exit
  terraform init
  terraform apply -var "factorio_version=${FACTORIO_VERSION}"
  popd || exit
}

destroy_infra() {
  pushd "infra/env/bielosx-$REGION" || exit
  terraform destroy
  popd || exit
  BUCKET_NAME=$(aws cloudformation describe-stacks --stack-name "$BACKEND_STACK" | jq -r '.Stacks[0].Outputs[0].OutputValue')
  aws s3 rm --recursive "s3://$BUCKET_NAME"
  aws cloudformation delete-stack --stack-name "$BACKEND_STACK"
  aws cloudformation wait stack-delete-complete --stack-name "$BACKEND_STACK"
}

build_image() {
  pushd image || exit
  packer build -var "factorio_version=${FACTORIO_VERSION}" .
  popd || exit
}

vagrant_up() {
  VERSION=${FACTORIO_VERSION} vagrant up
}

vagrant_destroy() {
  VERSION=${FACTORIO_VERSION} vagrant destroy
}

restore_saves() {
  aws ssm send-command --document-name factorio_saves_restore --targets Key=tag:Name,Values=factorio-server
}

get_instance_id() {
  INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=factorio-server" | \
    jq -r '.Reservations[0].Instances[0].InstanceId')
}

stop_instance() {
  get_instance_id
  aws ec2 stop-instances --instance-ids "$INSTANCE_ID"
}

start_instance() {
  get_instance_id
  aws ec2 start-instances --instance-ids "$INSTANCE_ID"
}

remove_images() {
  images=$(aws ec2 describe-images --filters "Name=tag:Name,Values=factorio-server-image")
  for k in $(echo "$images" | jq -r '.Images | keys | .[]'); do
    image=$(echo "$images" | jq -r ".Images[$k]")
    image_id=$(echo "$image" | jq -r '.ImageId')
    mapping_keys=$(echo "$image" | jq -r '.BlockDeviceMappings | keys | .[]')
    snapshot_ids=$(echo "$image" | jq -r '.BlockDeviceMappings | map(.Ebs.SnapshotId)')
    echo "Deleting AMI $image_id"
    aws ec2 deregister-image --image-id "$image_id"
    for id in $mapping_keys; do
      snapshot_id=$(echo "$snapshot_ids" | jq -r ".[$id]")
      echo "Deleting snapshot $snapshot_id"
      aws ec2 delete-snapshot --snapshot-id "$snapshot_id"
    done
  done
}

print_public_ip() {
  IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=factorio-server" | \
    jq -r '.Reservations[0].Instances[0].PublicIpAddress')
  echo "$IP"
}

case "$1" in
  "infra") deploy_infra ;;
  "destroy_infra") destroy_infra ;;
  "image") build_image ;;
  "vagrant_up") vagrant_up ;;
  "vagrant_destroy") vagrant_destroy ;;
  "restore_saves") restore_saves ;;
  "remove_images") remove_images ;;
  "start") start_instance ;;
  "stop") stop_instance ;;
  "ip") print_public_ip ;;
  *) echo "Actions: infra/destroy_infra/image/vagrant_up/vagrant_destroy/restore_saves/remove_images/start/stop/ip" ;;
esac

