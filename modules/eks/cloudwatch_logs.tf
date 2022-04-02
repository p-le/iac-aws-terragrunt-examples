# Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
resource "aws_cloudwatch_log_group" "cluster" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  count             = var.control_plane_logging.is_enabled ? 1 : 0
  name              = "/aws/eks/${aws_eks_cluster.app.name}/cluster"
  retention_in_days = var.control_plane_logging.retention_in_days
}
