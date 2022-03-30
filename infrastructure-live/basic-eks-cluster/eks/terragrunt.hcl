include "root" {
  path = find_in_parent_folders()
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

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  public_subnet_ids  = values(dependency.vpc.outputs.public_subnet_ids)
  private_subnet_ids = values(dependency.vpc.outputs.private_subnet_ids)
}
