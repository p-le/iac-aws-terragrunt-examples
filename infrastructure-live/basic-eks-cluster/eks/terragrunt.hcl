include "root" {
  path   = find_in_parent_folders()
  expose = true # Expose all attributes from root include
}

terraform {
  source = "./../../../modules//eks"
}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs when there are no outputs available
  # E.g: when vpc module hasn't been applied yet.
  mock_outputs = {
    vpc_id             = "temporary-vpc-id"
    public_subnet_ids  = {}
    private_subnet_ids = {}
  }
}

dependency "ec2_keypair" {
  config_path = "../ec2-keypair"

  # Configure mock outputs when there are no outputs available
  # E.g: when vpc module hasn't been applied yet.
  mock_outputs = {
    key_name = "temporary-key-name"
  }
}

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  public_subnet_ids  = values(dependency.vpc.outputs.public_subnet_ids)
  private_subnet_ids = values(dependency.vpc.outputs.private_subnet_ids)
  cluster_name       = "${include.root.inputs.service}-${include.root.inputs.region}-basic-cluster"
  key_name           = dependency.ec2_keypair.outputs.key_name
}
