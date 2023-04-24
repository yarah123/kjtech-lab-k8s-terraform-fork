# Azure Terraform for k8s

Deploy a minimal AKS cluster for PoCs and testing PlaceOS

## Prerequisites

Terraform version 1.4.5



Read [Getting Started with the Azure Provider](https://docs.microsoft.com/en-us/azure/developer/terraform/overview) for information on the use of Terraform with Azure

See the terraform page [Create K8s Cluster with TF and AKS](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks) used in this code.

## Deploy a network and minimal AKS cluster

Note: An azure System Managed Identity is created and used for the lifespan of the AKS cluster. [Managed Identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity#what-is-a-managed-identity)

eg using the `az` cli tool:

```sh

az login
az account set --subscription=[ YOUR SUBSCRIPTIION ID ]

```

Set the Resource Group Name that AKS will be deployed to in the terraform.tfvars file: `resource_group_name=[RESOURCE GROUP NAME]`

Set the Environment variable to define VM size and Tag for the cluster in the terraform.tfvars file, eg: `environment="Production"`
  - "Development" by default
  - "Production" will deploy suitable prod VMs
  - Anything else will deploy suitable dev VMs

Provision the infrastructure:

```sh
## Alternative to setting resource_group_name in terraform.tfvars file
export TF_VAR_resource_group_name=[RESOURCE GROUP NAME]

## Alternative to setting environment in terraform.tfvars file
export TF_VAR_environment=[ENVIRONMENT NAME]

## Initialise, plan and execute terraform
terraform init
terraform plan
terraform apply

```

Configure `kubectl` to connect to the newly deployed cluster

```sh
echo "$(terraform output kube_config)" > ./azurek8s
export KUBECONFIG=$(pwd)/azurek8s
# Validate your configuration
kubectl get nodes
```

Deploy a loadbalancer to expose the PlaceOS back office application and APIs.

**NOTE**: Not required if deploying PlaceOS with the provided ansible scripts in the k8s-helm repository

```sh

## Install Load Balancer. See https://hub.helm.sh/charts/ingress-nginx/ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install placeos -n ingress-nginx --create-namespace  ingress-nginx/ingress-nginx

```

**Note**: by adding the annotations in the ingress controller `LoadBalancer` service you can alternatively expose loadbalancer over an internal IP address only. See [internal-load-balancing](https://docs.microsoft.com/en-us/azure/aks/internal-lb)

Get the IP address of the Azure LoadBalancer Nginx is bound to. You will need this when you install the PlaceOS charts

```sh
# Get the status of the loadbalancer
kubectl get svc -n ingress-nginx
NAME                                          TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
placeos-ingress-nginx-controller             LoadBalancer   xx.xx.xx.xx      xx.xx.xx.xx     80:31307/TCP,443:31092/TCP   83s

# extract the public ip
kubectl get svc -n ingress-nginx placeos-ingress-nginx-controller -o=jsonpath='{.status.loadBalancer.ingress[*].ip}'

```

The extracted IP address needs to be added to the variable `global.placeDomain` for the helm chart deployment

## Cleanup Deployment

```sh
unset KUBECONFIG

# cleanup after
terraform plan --destroy
terraform destroy

```
