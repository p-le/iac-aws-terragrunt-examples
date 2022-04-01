locals {
  worker_node_userdata = templatefile("${path.module}/userdata.sh", {
    EKS_CLUSTER_NAME                  = aws_eks_cluster.app.name
    EKS_CLUSTER_ENDPOINT              = aws_eks_cluster.app.endpoint
    EKS_CLUSTER_CERTIFICATE_AUTHORITY = aws_eks_cluster.app.certificate_authority[0].data
  })
}

data "aws_ami" "woker_node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.app.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

resource "aws_launch_template" "worker_node" {
  name                   = "${var.service}-${var.region}-eks-launch-template"
  instance_type          = var.instance_type
  image_id               = data.aws_ami.woker_node.id
  user_data              = base64encode(local.worker_node_userdata)
  vpc_security_group_ids = [aws_security_group.woker_node_sg.id]
  key_name               = var.key_name

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_type           = "gp3"
      volume_size           = 20
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Environment = var.environment
      Region      = var.region
      Service     = var.service
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Environment = var.environment
      Region      = var.region
      Service     = var.service
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "primary" {
  node_group_name_prefix = "${var.service}-eks-primary-ng-"
  cluster_name           = aws_eks_cluster.app.name
  node_role_arn          = aws_iam_role.worker_node_role.arn
  subnet_ids             = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.worker_node.id
    version = "$Latest"
  }

  # EC2 Autoscaling Group Config
  scaling_config {
    desired_size = 3
    min_size     = 3
    max_size     = 5
  }

  # During node group update
  update_config {
    max_unavailable = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.cluster_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.cluster_node_AmazonEC2ContainerRegistryReadOnly,
  ]

  # Ignore changes related to desired_size
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# output "primary_node_group_asg_name" {
#   value = aws_eks_node_group.primary.resources.autoscaling_groups[0].name
# }
