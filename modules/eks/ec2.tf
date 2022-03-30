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
  instance_type          = "t2.micro"
  image_id               = data.aws_ami.woker_node.id
  user_data              = base64encode(local.worker_node_userdata)
  vpc_security_group_ids = [aws_security_group.woker_node_sg.id]
  ebs_optimized          = true
  key_name               = "test"

  iam_instance_profile {
    name = aws_iam_instance_profile.worker_node.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 20
    }
  }

  network_interfaces {
    associate_public_ip_address = false
  }

  tag_specifications {
    resource_type = "volume"

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

resource "aws_autoscaling_group" "worker_node" {
  name             = "${var.service}-${var.region}-eks-worker-node-asg"
  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  launch_template {
    id      = aws_launch_template.worker_node.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.private_subnet_ids

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Region"
    value               = var.region
    propagate_at_launch = true
  }

  tag {
    key                 = "Service"
    value               = var.service
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.app.name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
