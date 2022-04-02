variable "region" {
  type = string
}

variable "service" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "control_plane_logging" {
  type = object({
    is_enabled        = bool
    retention_in_days = number
  })
  default = {
    is_enabled        = false
    retention_in_days = 7
  }
}

variable "cluster_config" {
  type = object({
    use_private_subnet = bool
  })
  description = "use_private_subnet: Use Private Subnets or Public Subnets"
  default = {
    use_private_subnet = false
  }
}

variable "primary_node_group_config" {
  type = object({
    key_name           = string
    instance_type      = string
    use_private_subnet = bool
  })
  description = "key_name: EC2 Keypair Name, instance_type: Instance Type of Worker Node"
  default = {
    key_name           = ""
    instance_type      = "t3.micro"
    use_private_subnet = false
  }
}

variable "local_workstation_external_ip" {
  type        = string
  description = "Your local workstation external IP. Use https://whatismyipaddress.com/ to check"
  default     = ""
}
