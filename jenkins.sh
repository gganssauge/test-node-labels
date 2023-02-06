#!/bin/bash

set -ex

dockerfile=${1-Dockerfile}
# Use a random ID to enable parallel builds of the same project,
# both for the image name and the running container
imageId="$(od -vN "16" -An -tx1 /dev/urandom | tr -d " \n")"
containerId="provision_k8s_$imageId"

trap 'echo "ERROR: Check failed."' ERR

echo "INFO: Building temporary deployment image..."
docker build -t "$imageId" --pull --no-cache -f "$dockerfile" .
docker run \
  --rm \
  -e "ARM_CLIENT_ID=$DEV_SP_USR" \
  -e "ARM_CLIENT_SECRET=$DEV_SP_PSW" \
  -e "ARM_SUBSCRIPTION_ID=$DEV_SUBSCRIPTION_ID" \
  -e "ARM_TENANT_ID=$SP_TENANTID" \
  -e K8S_AGENT_COUNT \
  -e RESOURCE_GROUP \
  --name "$containerId" \
  "$imageId"

echo "Deleting image..."
docker rmi "${imageId}"
