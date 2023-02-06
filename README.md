# Provoke missing node labels in AKS cluster provisioned with terraform azurerm

- [Provoke missing node labels in AKS cluster provisioned with terraform azurerm](#provoke-missing-node-labels-in-aks-cluster-provisioned-with-terraform-azurerm)
  - [Problem statement](#problem-statement)
  - [Running the test](#running-the-test)
    - [Prerequisites](#prerequisites)
    - [Try to reproduce the problem](#try-to-reproduce-the-problem)
    - [Scripts](#scripts)

## Problem statement

Since azurerm version 1.39 we are experiencing problems with node labeling:
Our clusters have two agent pools labeled `stack=app` and `stack=monitoring` for application use and for monitorung use.

Our staging environment is created every night at about 5am and our production environment is created once a week at about 2am.

Both of these have already failed to provision due to that problem.

I created this test environment in order to reproduce the problem.

In about a third of the runs there are node labels missing:

~~~~text
02:46:16  ERROR: Number of agents for stack monitoring insufficient: required 2, actually 1
~~~~

The node actually got created as can be see on the azure portal but the required label is missing.

This repository contains a test environment to provoke the problem.

At our site we are testing it with a Jenkins job running every 20 minutes.

Over night I could see that about 9 out of 30 Jobs did fail with above mentioned message.

## Running the test

In order to run the tests you must have a few environment variables set in your environment *before* starting the test script:

| variable              | meaning                                          |
|-----------------------|--------------------------------------------------|
| `ARM_TENANT_ID`       | Azure tenant id                                  |
| `ARM_SUBSCRIPTION_ID` | Subscription id for the Azure subscription       |
| `ARM_CLIENT_ID`       | Application id (user) for the Azure subscription |
| `ARM_CLIENT_SECRET`   | Password for the Azure subscription              |

Afterwards run `make check` or `bash test-node-labels.sh`.

### Prerequisites

1. [terraform](https://www.terraform.io/)

### Try to reproduce the problem

- Run *make*
  
That runs a full cluster provisioning with 4 nodes in two node pools: app and monitoring.
The node pools get the labels `stack=app` resp. `stack=monitoring`.

### Scripts

The only script is `test-node-labels.sh` that does a full cluster provisioning, verifies the node labels and destroys the cluster.
It looks quite long - but that is caused by transplanting it from a working environment where some library functions were moved to the
script in order to make it work as a standalone script.

All the action happens at the bottom in the main function.

It basically comes down to:

- remove the state of the previous run (if any) - we don't want to maintain the generated resources
- create terraform.tfvars from the template in terraform.tfvars.template
- start `terraform -chdir=infrastructure/test-node-labels init`
- start `terraform -chdir=infrastructure/test-node-labels apply -auto-approve`
- Run the test verifying that the correct number of agents can be found with kubectl get node
- destroy the test cluster, again.
