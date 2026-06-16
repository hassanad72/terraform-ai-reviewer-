resource "aws_eks_cluster" "eks_cluster" {
  name     = "ai-reviewer-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.eks_subnet_1.id,
      aws_subnet.eks_subnet_2.id
    ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_attachment
  ]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "ai-reviewer-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids = [
    aws_subnet.eks_subnet_1.id,
    aws_subnet.eks_subnet_2.id
  ]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  instance_types = ["t3.small"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_role_attachment,
    aws_iam_role_policy_attachment.eks_cni_policy_attachment,
    aws_iam_role_policy_attachment.eks_ecr_pull_policy_attachment
  ]
}