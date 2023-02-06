#!/bin/bash

set -eu -o pipefail

LOCATION=northeurope; export LOCATION
RESOURCE_GROUP="${RESOURCE_GROUP-dev-test-$(date +%y%m%d%H%M)}"; export RESOURCE_GROUP
K8S_AGENT_COUNT=2; export K8S_AGENT_COUNT


infrastructure=./infrastructure
infrastructure_dir="$infrastructure/test-node-labels"

die() {
    echo "$@" >&1
    exit 1
}

# Check if a variable is empty or not. If it is empty, error message is issued and script exists with error
# Params: variable name, not value
checkVariableIsNotEmpty() {
    test $# -ne 0 || die "checkVariableIsNotEmpty: Missing variable name"

    while [[ $# -ne 0 ]] ; do
        local check="test -n \"\$$1\""
        # shellcheck disable=SC2154
        eval "$check" || die "ERROR: $1 must be set prior to calling this script. Exiting."
        shift
    done
}

info() {
    local level; level=${1:?info: parameter 'level' required}; shift

    echo "INFO [${level}]: " "$@"
}

separator() {
    echo "================================================="
}

#
# In all files of the form *.template found by a recursive search of the working directory
# strings looking like shell variable references will be
# replaced by the referenced environment variable.
#
# e.g. ${ABC} will be replaced by the value of environment variable ABC, likewise $ABC will work.
#
# Before searching for templates all existing results will be removed.
#
# Parameters:
#   none
#
template_files() {
    local targetFile

    separator; echo "Templating configuration..."
    echo "Cleaning up old templates..."
    find . -type f -name '*.template' | while read -r t; do
        targetFile=${t%.template}

        if [[ -f "$targetFile" ]]; then
            echo "Deleting ${targetFile}..."
            rm -f "$targetFile"
        fi
    done

    find . -type f -name '*.template' | while read -r t; do
        targetFile="${t%.template}"

        echo "Templating $t to $targetFile ..."
        perl -pe \
          's;(\\*)(\$([a-zA-Z_][a-zA-Z_0-9]*)|\$\{([a-zA-Z_][a-zA-Z_0-9]*)\})?;substr($1,0,int(length($1)/2)).($2&&length($1)%2?$2:$ENV{$3||$4});eg' \
          "$t" > "$targetFile"
    done

    echo "Done."
    separator
}

check_agent_nodes() {
    local stackname; stackname="${1:?check_agent_nodes: parameter 'stackname' required}"; shift
    local labelQuery; read -ra labelQuery <<< "-l stack=${stackname}"

    echo "INFO [k8s]: Testing stack ${stackname} ..."
    local timeout=3; # 30*10sec=30sec
    local number_of_agents

    for (( i = 1; i <= timeout; ++i )); do
        if number_of_agents="$(kubectl --kubeconfig=./kubeconfig get nodes "${labelQuery[@]}" | grep -F -c Ready)" ; then
            break
        fi

        echo "WARNING [k8s]: Could not connect to cluster correctly, waiting 10 seconds to try again..."
        sleep 10
    done

    if (( i > timeout )); then
        die "ERROR: Could not connect to k8s cluster!"
    fi

    if (( number_of_agents < "$K8S_AGENT_COUNT" )); then
        die "ERROR: Number of agents for stack $stackname insufficient: required $K8S_AGENT_COUNT, actually $number_of_agents"
    fi
    echo "INFO [k8s]: Test succeeded for stack ${stackname}"
}

get_cluster_configuration() {
    local infrastructure_dir; infrastructure_dir=${1:?get_cluster_configuration: parameter 'infrastructure_dir' required}; shift

    rm -f "./kubeconfig" && \
      true > "./kubeconfig" && \
      chmod 600 "./kubeconfig" && \
      terraform -chdir="$infrastructure_dir" output -raw "kubeconfig" >> "./kubeconfig"
}

runtests() {
    local infrastructure_dir; infrastructure_dir=${1:?runtests: parameter 'infrastructure_dir' required}; shift

    get_cluster_configuration "$infrastructure_dir"

    info "Check app nodes"
    check_agent_nodes app
    info "Check monitoring nodes"
    check_agent_nodes monitoring
    info "Done testing"
}

cleanup() {
    terraform "-chdir=$infrastructure_dir" destroy -auto-approve >/dev/null
}

trap "cleanup" 0

main() {
    info "k8s" "Agent node count: $K8S_AGENT_COUNT."

    checkVariableIsNotEmpty ARM_CLIENT_ID ARM_CLIENT_SECRET ARM_SUBSCRIPTION_ID ARM_TENANT_ID

    # az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID" -o none
    # az account set --subscription "$ARM_SUBSCRIPTION_ID" -o none

    # remove the state - we dont plan to maintain that cluster
    rm -f $infrastructure_dir/*.tfstate*

    # replace variable references in the terraform.tfvars file
    template_files

    # initialize the providers
    terraform -chdir="$infrastructure_dir" init -no-color

    # build the test cluster
    terraform -chdir="$infrastructure_dir" apply -no-color -auto-approve

    separator
    echo "Running tests"
    runtests "$infrastructure_dir"
}

main
