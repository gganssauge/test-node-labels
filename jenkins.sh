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
docker run --rm --env-file variables.env --name "$containerId" "$imageId"

echo "Deleting image..."
docker rmi "${imageId}"
