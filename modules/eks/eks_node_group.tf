data "aws_ami" "worker_node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.app.version}-v*"]
  }

  most_recent = true
  owners      = ["amazon"]
}

resource "aws_eks_node_group" "primary" {
  node_group_name_prefix = "${var.service}-eks-primary-ng-"
  cluster_name           = aws_eks_cluster.app.name
  node_role_arn          = aws_iam_role.worker_node_role.arn
  subnet_ids             = var.primary_node_group_config.use_private_subnet ? var.private_subnet_ids : var.public_subnet_ids
  ami_type               = "AL2_x86_64"
  capacity_type          = "ON_DEMAND"
  disk_size              = 20
  instance_types         = [var.primary_node_group_config.instance_type]

  # EC2 Autoscaling Group Config
  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 5
  }

  # During node group update
  update_config {
    max_unavailable = 1
  }

  remote_access {
    ec2_ssh_key = var.primary_node_group_config.key_name
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.cluster_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.cluster_node_AmazonEC2ContainerRegistryReadOnly,
    kubernetes_config_map.aws_auth
  ]

  # Ignore changes related to desired_size
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }
}
