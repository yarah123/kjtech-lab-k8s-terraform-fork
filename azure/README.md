# Azure Terraform for k8s

Deploy a minimal AKS cluster for PoCs and testing PlaceOS

## Prerequisites

Terraform version 0.13.3

Read [Getting Started with the Azure Provider](https://docs.microsoft.com/en-us/azure/developer/terraform/overview) to set up your environment.

See the terraform page [Create K8s Cluster with TF and AKS](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks) used in this code.

## Deploy a network and minimal AKS cluster

Note: An azure service principal is required for the AKS cluster.  See [Create the service principal](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest). Take note of the values for the appId, displayName, password, and tenant.

eg using the `az` cli tool:

```sh

az login
az account set --subscription=[ YOUR SUBSCRIPTIION ID ]
az ad sp create-for-rbac --name AksServicePrinciple

```

Set the Resource Group Name that AKS will be deployed to in the terraform.tfvars file: `resource_group_name=[RESOURCE GROUP NAME]`

Provision the infrastructure:

```sh
##

export TF_VAR_aks_sp_app_pw=[ AKS SERVICE PRINCIPLE PASSWORD ]
export TF_VAR_aks_sp_app_id=[ AKS SERVICE PRINCIPLE ID ]
## Alternative to setting resource_group_name in terraform.tfvars file
export TF_VAR_resource_group_name=[RESOURCE GROUP NAME]

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
