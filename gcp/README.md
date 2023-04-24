# GCP Terraform for k8s

Deploy a minimal GKE cluster for PoCs and testing PlaceOS

## Prerequisites

Terraform version 1.4.5

Read [Getting Started with the Google Provider](https://www.terraform.io/docs/providers/google/guides/getting_started.html) to set up your environment.

See the official terraform [kubernetes engine module](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/3.0.0) used in this code.

## Deploy a network and minimal GKE cluster

```sh
## Set the GCP project Id.
export TF_VAR_project_id=[GCP_PROJECT_ID]
## Initialise, plan and execute terraform
terraform init
terraform plan
terraform apply

```

Deploy a cloud loadbalancer to expose the PlaceOS back office application and APIs.

**NOTE**: Not required if deploying PlaceOS with the provided ansible scripts in the k8s-helm repository

```sh
# get the name of the gke cluster:
terraform output cluster_name
# retrive and set local kubeconfig file to access the GKE cluster
gcloud container clusters get-credentials [THE CLUSTER NAME] --region australia-southeast1 --project ${TF_VAR_project_id}
#eg using the terraform command to retreive the cluster name dynamically
gcloud container clusters get-credentials $( terraform output cluster_name )  --region australia-southeast1 --project ${TF_VAR_project_id}
# validate your local kube config settings
kubectl cluster-info

## Install Load Balancer. See https://hub.helm.sh/charts/ingress-nginx/ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install placeos -n ingress-nginx --create-namespace  ingress-nginx/ingress-nginx

```

**Note**: by adding the annotations in the ingress controller `LoadBalancer` service you can alternatively expose loadbalancer over an internal IP address only. See [internal-load-balancing](https://cloud.google.com/kubernetes-engine/docs/how-to/internal-load-balancing)

Get the IP address of the GCP LoadBalancer Nginx is bound to. You will need this when you install the PlaceOS charts

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
# cleanup after
export TF_VAR_project_id=[GCP_PROJECT_ID]

terraform plan --destroy
terraform destroy

```
