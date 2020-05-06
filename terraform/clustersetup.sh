#!/usr/bin/env bash

set -e -o pipefail

#Initializing and Creating the VPC environment
terraform init
terraform apply --auto-approve

#creating variables
TF_OUTPUT=$(cd ../terraform && terraform output -json)
CLUSTER_NAME="$(echo ${TF_OUTPUT} | jq -r .kubernetes_cluster_name.value)"
STATE="s3://$(echo ${TF_OUTPUT} | jq -r .kops_s3_bucket.value)"

#change dir to kubernetes-cluster
cd ../kubernetes-cluster

#Generating cluster.yaml from cluster-template.yaml using kops toolbox template
kops toolbox template --name ${CLUSTER_NAME} --values <( echo ${TF_OUTPUT}) --template cluster-template.yaml --format-yaml > cluster.yaml

#storing the kops state in s3
kops replace -f cluster.yaml --state ${STATE} --name ${CLUSTER_NAME} --force


#creating public key file and assigning it to nodes
kops create secret --name ${CLUSTER_NAME} --state ${STATE} sshpublickey admin -i ~/.ssh/id_rsa.pub


#update the cluster state file and generating a terraform file
kops update cluster --target terraform --state ${STATE} --name ${CLUSTER_NAME} --out .

#Initializing and launching a cluster
terraform init
terraform apply -target aws_internet_gateway.myfirstcluster-k8s-local
terraform apply -target aws_elb.api-myfirstcluster-k8s-local --auto-approve
kops update cluster --target terraform --state ${STATE} --name ${CLUSTER_NAME} --out .
terraform apply --auto-approve


#exporting the configuration for kubectl
kops export kubecfg --name ${CLUSTER_NAME} --state ${STATE}

#validating the cluster until it gets succeeded
until kops validate cluster --state ${STATE}
do
    echo "Cluster is not yet ready. Sleeping for a while..."
    sleep 45
done

