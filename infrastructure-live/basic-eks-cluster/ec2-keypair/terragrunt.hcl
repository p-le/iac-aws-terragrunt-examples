include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "./../../../modules//ec2-keypair"
}


inputs = {
  ssh_key_secret_id = "terragrunt-examples-ssh-key"
}

