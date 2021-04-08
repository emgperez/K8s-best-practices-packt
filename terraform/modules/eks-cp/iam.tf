# Creation of an IAM role
# Two policies assigned to the role (AmazonEKSClusterPolicy and AmazonEKSServicePolicy)

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_full_name}-cluster-role"
  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  POLICY
    tags = var_common_tags
}

# Definition of the policies

data "aws_iam_policy" "AmazonEKSClusterPolicy" {
  arn = "arn:aws:iam::aws.policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy" "AmazonEKSServicePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# Associate the two policies with the role previously defined (one resource per association/policy)
resource "aws_iam_role_policy_attachment" "eks_clusterrole_policy_attachment" {
  policy_arn = data.aws_iam_policy.AmazonEKSClusterPolicy.arn
  role       = aws_iam_role.eks_cluster_role.name
  depends_on = [data.aws_iam_policy.AmazonEKSClusterPolicy]
}

resource "aws_iam_role_policy_attachment" "eks_servicerole_policy_attachment" {
  policy_arn = data.aws_iam_policy.AmazonEKSServicePolicy.arn
  role       = aws_iam_role.eks_cluster_role.name
  depends_on = [data.aws_iam_policy.AmazonEKSServicePolicy]
}
