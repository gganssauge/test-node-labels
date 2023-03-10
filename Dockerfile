FROM registry.haufe.io/aurora/aurora.k8s.deploy.env:latest

WORKDIR /root/deploy
COPY . ./
ENV TF_CLI_ARGS_apply=-no-color
ENV TF_CLI_ARGS_destroy=-no-color
ENTRYPOINT ["/bin/bash", "test-node-labels.sh"]
