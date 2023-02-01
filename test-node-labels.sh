#!/bin/bash

set -eu -o pipefail

LOCATION=northeurope; export LOCATION
RESOURCE_GROUP="${RESOURCE_GROUP-dev-test-$(date +%Y%m%d%H%M)}"; export RESOURCE_GROUP

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

azure_login() {
    export SP_APPID="$DEV_SP_APPID"
    export SP_PASSWORD="$DEV_SP_PASSWORD"
    export SUBSCRIPTION_ID="$DEV_SUBSCRIPTION_ID"

    az login --service-principal -u "$SP_APPID" -p "$SP_PASSWORD" --tenant "$SP_TENANTID"
    az account set --subscription "$SUBSCRIPTION_ID"

    # terraform does need these to authenticate
    ARM_CLIENT_ID="$SP_APPID"; export ARM_CLIENT_ID
    ARM_CLIENT_SECRET="$SP_PASSWORD"; export ARM_CLIENT_SECRET
    ARM_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"; export ARM_SUBSCRIPTION_ID
    ARM_TENANT_ID="$SP_TENANTID"; export ARM_TENANT_ID
}

remove_terraform_state() {
    local module_dir; module_dir="${1:?remove_terraform_state: parameter 'module_dir' required}"

    (
        cd "$module_dir" || die "Module $module_dir not found"
        rm -f ./*.tfstate*
    )
}

#
# run terraform in the given directory
#
# $1 - directory where to run terraform
#
terraform_in_module() {
    # the shift is required to remove the module_dir from $@
    local module_dir; module_dir="${1:?terraform_in_module: parameter 'module_dir' required}"; shift

    ARM_SKIP_PROVIDER_REGISTRATION=true \
        terraform -chdir="${module_dir}" "$@"
}

separator() {
    echo "================================================="
}

# Echo a separator followed by the given text
separated() {
    separator
    echo "$@"
}


#
# Internal implementation of the clean-templated-yamls.sh script
#
# this will remove the results of a previous template_yamls call
#
# Parameters:
#   none
#
# Example:
#   clean_templated_files
#
clean_templated_files() {
    find . -type f -name '*.template' | while read -r t; do
        targetFile=${t%.template}
        if [[ -f "$targetFile" ]]; then
            echo "Deleting ${targetFile}..."
            rm -f "$targetFile"
        fi
    done
}

#
# implementation of template_files for a single file.
# does not remove the target file prior to running
#
template_file() {
    local template; template=${1:?template_file: parameter 'template' required}
    local targetFile; targetFile="${template%.template}"

    echo "Templating $template to $targetFile ..."
    perl -pe \
      's;(\\*)(\$([a-zA-Z_][a-zA-Z_0-9]*)|\$\{([a-zA-Z_][a-zA-Z_0-9]*)\})?;substr($1,0,int(length($1)/2)).($2&&length($1)%2?$2:$ENV{$3||$4});eg' \
      "$template" > "$targetFile"
}

#
# Internal implementation of the template-yamls.sh script.
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
# Example:
#   template_files
#
template_files() {
    separated "Templating configuration..."
    echo "Cleaning up old templates..."
    clean_templated_files

    find . -type f -name '*.template' | while read -r t; do
        template_file "$t"
    done

    echo "Done."
    separator
}

#
# apply the terraform module.
#
# $1 - module directory
# $2 - if this is not empty then the apply operation is automatically approved
#
apply_terraform_module() {
    local module_dir; module_dir="${1:?build_terraform_module-server: parameter 'module_dir' required}"
    local do_confirm; do_confirm="${2:-}"
    local do_upgrade; do_upgrade="${3:-}"

    if [[ "$do_upgrade" == "yes" ]]; then
        upgrade_flag="-upgrade"
    fi

    [[ -d "$module_dir" ]] || die "apply_terraform_module: $module_dir is not a directory"

    (
        cd "$module_dir" && template_files
        cat terraform.tfvars
    )

    # do not quote ${upgrade_flag-} - if empty it would add a forbidden empty argument to the terraform command line
    # shellcheck disable=SC2086
    terraform_in_module "${module_dir}" init -no-color ${upgrade_flag-}

    local approve

    if [[ "$do_confirm" ]]; then
        approve=-auto-approve
    else
        approve=""
    fi

    terraform_in_module "${module_dir}" plan -no-color -out=plan.out
    terraform_in_module "${module_dir}" apply -no-color "$approve" plan.out
}

check_agent_nodes() {
    local stackname; stackname="${1:?check_agent_nodes: parameter 'stackname' required}"; shift
    local agent_count; agent_count="${1:?check_agent_nodes: parameter 'agent_count' required}"; shift
    local labelQuery; read -ra labelQuery <<< "-l stack=${stackname}"

    echo "INFO [k8s]: Checking k8s connectivity for stack ${stackname} ..."
    local timeout=30; # 30*10sec=5minutes
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

    if (( number_of_agents < agent_count )); then
        die "ERROR: Number of agents for stack $stackname insufficient: required $agent_count, actually $number_of_agents"
    fi
    echo "INFO [k8s]: Connectivity established for stack ${stackname}"
}

info() {
    local level; level=${1:?info: parameter 'level' required}; shift

    echo "INFO [${level}]: " "$@"
}

get_cluster_configuration() {
    local infrastructure_dir; infrastructure_dir=${1:?get_cluster_configuration: parameter 'infrastructure_dir' required}; shift

    kubeconfig="$PWD/kubeconfig"
    rm -f "$kubeconfig" && \
      true > "$kubeconfig" && \
      chmod 600 "$kubeconfig" && \
      terraform_in_module "$infrastructure_dir" output -raw "kubeconfig" >> "$kubeconfig"
    echo "$kubeconfig"
}

runtests() {
    local infrastructure_dir; infrastructure_dir=${1:?runtests: parameter 'infrastructure_dir' required}; shift

    get_cluster_configuration "$infrastructure_dir"

    info "Check app nodes"
    check_agent_nodes app $K8S_AGENT_COUNT
    info "Check monitoring nodes"
    check_agent_nodes monitoring $K8S_MONITOR_COUNT
    info "Done testing"
}

remove_group() {
    local resource_group="${1?group_exists: Missing parameter: resource group}"

    echo "Deleting resource group $resource_group"

    az group delete --name "$resource_group" --yes >/dev/null 2>&1 || true
}

K8S_AGENT_COUNT=2; export K8S_AGENT_COUNT
K8S_MONITOR_COUNT=2; export K8S_MONITOR_COUNT
KUBECONFIG="$PWD/kubeconfig"; export KUBECONFIG

# The creator is either externally set or it is the current user
CREATOR="${CREATOR:-${USER:-"$0"}}"; export CREATOR
# The hostname should be either externally set or it is the local hostname
HOST_NAME="${HOST_NAME:-${HOSTNAME:-"$(hostname -f)"}}"; export HOST_NAME
CLUSTER_NAME=TEST; export CLUSTER_NAME

cleanup() {
    terraform "-chdir=$infrastructure_dir" destroy -auto-approve
}

trap "cleanup" 0

main() {
    info "k8s" "App node count: $K8S_AGENT_COUNT."
    info "k8s" "Monitor node count: $K8S_MONITOR_COUNT."

    checkVariableIsNotEmpty DEV_SP_APPID DEV_SP_PASSWORD DEV_SUBSCRIPTION_ID SP_TENANTID

    azure_login

    remove_terraform_state "$infrastructure_dir"
    # shellcheck disable=SC2086
    apply_terraform_module "$infrastructure_dir" "yes"

    echo "Running tests"
    runtests "$infrastructure_dir"
}

main
