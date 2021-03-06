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
  private_subnets        = ["10.0.1.0/24"]
  public_subnets         = ["10.0.101.0/24"]
  environment            = "dev"
  cluster_name           = "xcluster"
  kops_state_bucket_name = "${local.environment}-kops-state-example"
  // Needs to be a FQDN
  kubernetes_cluster_name = "${local.cluster_name}.k8s.local"
  ingress_ips             = ["10.0.0.100/32", "10.0.0.101/32", "54.69.253.153/32", "34.219.192.132/32"]
  vpc_name                = "${local.environment}-vpc"

  tags = {
    environment = "${local.environment}"
    terraform   = true
  }
}

data "aws_region" "current" {}
