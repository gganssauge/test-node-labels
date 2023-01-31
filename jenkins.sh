#!/bin/bash

set -ex

dockerfile=${1-Dockerfile}
# Use a random ID to enable parallel builds of the same project,
# both for the image name and the running container
imageId="$(od -vN "16" -An -tx1 /dev/urandom | tr -d " \n")"
containerId="provision_k8s_$imageId"

trap 'echo "ERROR: Check failed."' ERR

env | sort

if [ -z "$K8SADMIN_ID_RSA_PATH" ] || [ -z "$K8SADMIN_ID_RSA_PUB_PATH" ]; then
    echo "ERROR: Env vars K8SADMIN_ID_RSA_PATH and K8SADMIN_ID_RSA_PUB_PATH must point to an ssh"
    echo "identity for the user k8sadmin."
    exit 1
fi

if [ -z "$TRANSFER_ID_RSA_PATH" ] || [ -z "$TRANSFER_ID_RSA_PUB_PATH" ]; then
    echo "ERROR: Env vars TRANSFER_ID_RSA_PATH and TRANSFER_ID_RSA_PUB_PATH must point to an ssh"
    echo "identity for the user transfer."
    exit 1
fi

K8SADMIN_PUBKEY="./k8sadmin.id_rsa.pub"; export K8SADMIN_PUBKEY
K8SADMIN_KEY="./k8sadmin.id_rsa"; export K8SADMIN_KEY
TRANSFER_PUBKEY="./transfer.id_rsa.pub"; export TRANSFER_PUBKEY
TRANSFER_KEY="./transfer.id_rsa"; export TRANSFER_KEY

cp -f "$K8SADMIN_ID_RSA_PATH" "$K8SADMIN_KEY"
cp -f "$K8SADMIN_ID_RSA_PUB_PATH" "$K8SADMIN_PUBKEY"

cp -f "$TRANSFER_ID_RSA_PATH" "$TRANSFER_KEY"
cp -f "$TRANSFER_ID_RSA_PUB_PATH" "$TRANSFER_PUBKEY"

echo "INFO: Building temporary deployment image..."
docker build -t "$imageId" --pull --no-cache -f "$dockerfile" .
docker run --rm --env-file variables.env --name "$containerId" "$imageId"

echo "Deleting image..."
docker rmi "${imageId}"
