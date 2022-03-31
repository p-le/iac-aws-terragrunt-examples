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
  type    = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "controle_plane_logging" {
  type = object({
    is_enabled        = bool
    retention_in_days = number
  })
  default = {
    is_enabled        = false
    retention_in_days = 7
  }
}

variable "local_workstation_external_ip" {
  type        = string
  description = "Your local workstation external IP. Use https://whatismyipaddress.com/ to check"
  default     = ""
}
