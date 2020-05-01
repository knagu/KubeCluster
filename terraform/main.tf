provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "tf-state-kube"
    key    = "dev/terraform"
    region = "us-west-2"
  }
}

locals {
  azs                    = ["us-west-2a"]
  environment            = "dev"
  kops_state_bucket_name = "${local.environment}-kops-state-example"
  // Needs to be a FQDN
  kubernetes_cluster_name = "myfirstcluster.k8s.local"
  ingress_ips             = ["10.0.0.100/32", "10.0.0.101/32", "54.69.253.153/32"]
  vpc_name                = "${local.environment}-vpc"

  tags = {
    environment = "${local.environment}"
    terraform   = true
  }
}

data "aws_region" "current" {}
