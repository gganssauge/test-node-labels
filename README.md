# Provoke missing node labels in AKS cluster provisioned with terraform azurerm

Since azurerm version 1.39 we are experiencing problems with node labeling.

- [Provoke missing node labels in AKS cluster provisioned with terraform azurerm](#provoke-missing-node-labels-in-aks-cluster-provisioned-with-terraform-azurerm)
  - [Implementation](#implementation)
    - [module *cluster-resource-group*](#module-cluster-resource-group)
    - [module *k8s*](#module-k8s)
    - [module *tags*](#module-tags)
    - [Provisioning of a test cluster](#provisioning-of-a-test-cluster)
    - [Prerequisites](#prerequisites)
    - [Try to reproduce the problem](#try-to-reproduce-the-problem)
    - [Scripts](#scripts)


## Implementation

The provisioning is performed using terraform. The necessary terraform modules are located in subdirectory `infrastructure`.

### module *cluster-resource-group*

Create a resource group for the cluster.

see [infrastructure/modules/cluster-resource-group](./infrastructure/modules/cluster-resource-group/README.md).

### module *k8s*

This module is responsible for creating an AKS cluster in a given resource group.

see [infrastructure/modules/k8s](./infrastructure/modules/k8s/README.md).

### module *tags*

This manages the standard tags required by the Haufe internal cloud platform.

see [infrastructure/modules/tags](./infrastructure/modules/tags/README.md).

### Provisioning of a test cluster

A test cluster is provisioned using the script `test-node-labels.sh`. It generates input variables for the provisioning from the provided parameters and then calls terraform to create the structure defined in `infrastructure/test-node-labels`.

see [infrastructure/test-node-labels](./infrastructure/test-node-labels/README.md)

### Prerequisites

1. [terraform](https://www.terraform.io/)

### Try to reproduce the problem

- Run *make*
  
That runs a full cluster provisioning with 4 nodes in two node pools: app and monitoring.
The node pools get the labels `stack=app` resp. `stack=monitoring`.

### Scripts

The only script is `test-node-labels.sh` that does a full cluster provisioning, verifies the node labels and destroys the cluster.

In order to use it you must have a few environment variables set in your environment *before* starting the remote container:

| variable                  | meaning                                               |
|---------------------------|-------------------------------------------------------|
| `SP_TENANTID`             | Azure tenant id                                       |
| `DEV_SUBSCRIPTION_ID`     | Subscription id for the Azure subscription            |
| `DEV_SP_APPID`            | Application id (user) for the Azure subscription      |
| `DEV_SP_PASSWORD`         | Password for the Azure subscription                   |
