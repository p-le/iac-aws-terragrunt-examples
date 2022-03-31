include "root" {
  path   = find_in_parent_folders()
  expose = true # Expose all attributes from root include
}

terraform {
  source = "./../../../modules//vpc"
}

inputs = {
  eks_cluster_name = "${include.root.inputs.service}-${include.root.inputs.region}-basic-cluster"
}
