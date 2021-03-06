data "aws_eks_cluster_auth" "app" {
  name = aws_eks_cluster.app.name
}

resource "aws_eks_cluster" "app" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids             = var.cluster_config.use_private_subnet ? var.private_subnet_ids : var.public_subnet_ids
    security_group_ids     = [aws_security_group.cluster_sg.id]
    endpoint_public_access = true
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_role_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_role_AmazonEKSVPCResourceController,
  ]
}

output "cluster_name" {
  value = aws_eks_cluster.app.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.app.endpoint
}

output "cluster_kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.app.certificate_authority[0].data
}
