#!/bin/bash

FACTORIO_VERSION="1.1.53"
export AWS_DEFAULT_REGION=eu-central-1

deploy_infra() {
  aws cloudformation deploy --template-file infra/terraform_backend.yaml --stack-name terraform-backend
  pushd infra/env/bielosx-eu-central-1 || exit
  terraform init
  terraform apply -var "factorio_version=${FACTORIO_VERSION}"
  popd || exit
}

destroy_infra() {
  pushd infra/env/bielosx-eu-central-1 || exit
  terraform destroy
  popd || exit
  BUCKET_NAME=$(aws cloudformation describe-stacks --stack-name terraform-backend | jq -r '.Stacks[0].Outputs[0].OutputValue')
  aws s3 rm --recursive "s3://$BUCKET_NAME"
  aws cloudformation delete-stack --stack-name terraform-backend
  aws cloudformation wait stack-delete-complete --stack-name terraform-backend
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

case "$1" in
  "infra") deploy_infra ;;
  "destroy_infra") destroy_infra ;;
  "image") build_image ;;
  "vagrant_up") vagrant_up ;;
  "vagrant_destroy") vagrant_destroy ;;
  *) echo "infra/image/vagrant_up/vagrant_destroy" ;;
esac