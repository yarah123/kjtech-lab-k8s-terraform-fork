# GCP Terraform for k8s

Terraform version 0.13.3

Read [Getting Started with the Google Provider](https://www.terraform.io/docs/providers/google/guides/getting_started.html) to set up your environment.

See the official terraform [kubernetes engine module](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/3.0.0) used in this code.



```

export TF_VAR_project_id=[GCP_PROJECT_ID]
terraform init
terraform plan
terraform apply

```