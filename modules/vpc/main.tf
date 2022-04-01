resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = var.eks_cluster_name != "" ? {
    "kubernetes.io/cluster/${var.eks_cluster_name}" : "shared"
  } : {}
}

resource "aws_subnet" "public" {
  for_each          = toset(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, index(data.aws_availability_zones.available.names, each.value) + 11)

  tags = var.eks_cluster_name != "" ? {
    "kubernetes.io/cluster/${var.eks_cluster_name}" : "shared"
  } : {}
}

resource "aws_subnet" "private" {
  for_each                = toset(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.value
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, index(data.aws_availability_zones.available.names, each.value) + 21)
  map_public_ip_on_launch = false

  tags = var.eks_cluster_name != "" ? {
    "kubernetes.io/cluster/${var.eks_cluster_name}" : "shared"
  } : {}
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = {
    for availability_zone in data.aws_availability_zones.available.names : availability_zone => aws_subnet.public[availability_zone].id
  }
}

output "private_subnet_ids" {
  value = {
    for availability_zone in data.aws_availability_zones.available.names : availability_zone => aws_subnet.private[availability_zone].id
  }
}
