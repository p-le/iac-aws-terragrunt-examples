variable "region" {
  type = string
}

variable "service" {
  type = string
}

variable "environment" {
  type = string
}

variable "eks_cluster_name" {
  type    = string
  default = ""
}
