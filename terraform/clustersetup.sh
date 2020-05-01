#!/usr/bin/env bash

set -e -o pipefail

terraform init
terraform apply --auto-approve
TF_OUTPUT=$(cd ../terraform && terraform output -json)
CLUSTER_NAME="$(echo ${TF_OUTPUT} | jq -r .kubernetes_cluster_name.value)"
STATE="s3://$(echo ${TF_OUTPUT} | jq -r .kops_s3_bucket.value)"
cd ../kubernetes-cluster
kops toolbox template --name ${CLUSTER_NAME} --values <( echo ${TF_OUTPUT}) --template cluster-template.yaml --format-yaml > cluster.yaml
kops replace -f cluster.yaml --state ${STATE} --name ${CLUSTER_NAME} --force
kops create secret --name ${CLUSTER_NAME} --state ${STATE} sshpublickey admin -i ~/.ssh/id_rsa.pub
kops update cluster --target terraform --state ${STATE} --name ${CLUSTER_NAME} --out .
terraform apply -target aws_internet_gateway.myfirstcluster-k8s-local
terraform apply -target aws_elb.api-myfirstcluster-k8s-local --auto-approve
kops update cluster --target terraform --state ${STATE} --name ${CLUSTER_NAME} --out .
terraform apply --auto-approve
kops export kubecfg --name ${CLUSTER_NAME} --state ${STATE}

until kops validate cluster --state ${STATE}
do
    echo "Cluster is not yet ready. Sleeping for a while..."
    sleep 30
done

