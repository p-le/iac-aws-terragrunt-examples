# Controls networking access to the Kubernetes masters
resource "aws_security_group" "cluster_sg" {
  name        = "${var.service}-${var.region}-eks-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound traffic from your local workstation external IP to the EKS Cluster
  dynamic "ingress" {
    for_each = toset(compact([var.local_workstation_external_ip]))
    content {
      description = "Allow local workstation to communicate with the EKS Cluster API Server"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["${ingress.value}/32"]
    }
  }
}

# Controls networking access to the Kubernetes worker nodes
resource "aws_security_group" "woker_node_sg" {
  name        = "${var.service}-${var.region}-eks-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow node to communicate with each other"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster_sg.id]
  }

  ingress {
    description     = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster_sg.id]
  }

  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.app.name}" : "owned"
  }
}

# Use aws_security_group_rule to avoid cycle reference
resource "aws_security_group_rule" "cluster_ingress_worker_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  to_port                  = 443
  type                     = "ingress"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.woker_node_sg.id
}
