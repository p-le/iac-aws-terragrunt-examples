include "root" {
  path   = find_in_parent_folders()
  expose = true # Expose all attributes from root include
}

terraform {
  source = "./../../../modules//eks"
}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs of vpc modules when there are no outputs available
  # E.g: when vpc module hasn't been applied yet.
  mock_outputs = {
    vpc_id = "temporary-vpc-id"
    public_subnet_ids = {
      "dummy-zone" : "dummy-subnet-id"
    }
    private_subnet_ids = {
      "dummy-zone" : "dummy-subnet-id"
    }
  }
}

dependency "ec2_keypair" {
  config_path = "../ec2-keypair"

  # Configure mock outputs of ec2_keypair module when there are no outputs available
  # E.g: when ec2_keypair module hasn't been applied yet.
  mock_outputs = {
    key_name = "temporary-key-name"
  }
}

dependency "external_ip" {
  config_path = "../external-ip"

  # Configure mock outputs of external-ip module when there are no outputs available
  # E.g: when external-ip module hasn't been applied yet.
  mock_outputs = {
    external_ip = "1.1.1.1"
  }
}

inputs = {
  vpc_id                        = dependency.vpc.outputs.vpc_id
  public_subnet_ids             = values(dependency.vpc.outputs.public_subnet_ids)
  private_subnet_ids            = values(dependency.vpc.outputs.private_subnet_ids)
  cluster_name                  = "${include.root.inputs.service}-${include.root.inputs.region}-basic-cluster"
  local_workstation_external_ip = dependency.external_ip.outputs.external_ip
  primary_node_group_config = {
    key_name           = dependency.ec2_keypair.outputs.key_name
    instance_type      = "t3.micro"
    use_private_subnet = false
  }
}

generate "provider" {
  path      = "provider_k8s.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.9.0"
    }
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.app.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.app.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.app.token
}
EOF
}
