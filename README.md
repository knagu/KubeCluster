# Deploying Kubernetes clusters in AWS using kops and Terraform



# Pre-requisites

* confifure aws credentials using aws configure
* jq
* kops
* kubectl
* terraform
* s3 bucket for storing terraform state

## Usage

Edit `terraform/main.tf` with your local variables 

From the `terraform` directory run:

./clustersetup.sh
