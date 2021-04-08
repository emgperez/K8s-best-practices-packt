# Workers security group, including ingress/egress rules to control traffic flow between workers and between masters (control plane) and workers

resource "aws_security_group" "workers" {
  name = "${var.cluster_full_name}-workers"
  description = "Security Group for all worker nodes in the ${var.cluster_full_name} cluster"
  vpc_id = var.vpc_id
  
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" # protocol -1 = protocol all
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.cluster_full_name}-cluster-sg"
      "kubernetes.io/cluster/${var.cluster_full_name}" = "owned"
    },
  )
}

# Traffic between worker nodes (both TCP and UDP)
resource "aws_security_group_rule" "worker_to_worker_tcp" {
  description = "Allow tcp communication between worker nodes"
  from_port = 0
  protocol = "tcp"
  security_group_id = aws_security_group.workers.id
  source_security_group_id = aws_security_group.workers.id
  to_port = 65535
  type = "ingress"
}

resource "aws_security_group_rule" "worker_to_workder_udp" {
  description = "Allow udp communication between worker nodes"
  from_port = 0
  protocol = "udp"
  security_group_id = aws_security_group.workers.id
  source_security_group_id = aws_security_group.workers.id
  to_port = 65535
  type = "ingress"
}

# Traffic between worker nodes and master nodes
resource "aws_security_group_rule" "workers_masters_ingress" {
  description = "Allow worker kubelets and pods to receive communication from the master nodes (control plane)"
  from_port = 1025
  to_port = 65535
  protocol = "tcp"
  security_group_id = aws_security_group.workers.id
  source_security_group_id = var.cluster_security_group
  type = "ingress"
}

resource "aws_security_group_rule" "workers_masters_https_ingress" {
  description = "Allow worker kubelets and pods to receive https traffic from the master nodes (control plane)"
  from_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.workers.id
  source_security_group_id = var.cluster_security_group
  to_port = 443
  type = "ingress"
}

# Traffic from the workers to the API server
resource "aws_security_group_rule" "masters_api_ingress" {
  description = "Allow cluster control plane to receive communication from workers kubelets and pods"
  from_port = 443
  protocol = "tcp"
  security_group_id = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  to_port = 443
  type = "ingress"
}

# Traffic from the master nodes to the workers kubelet and pods
resource "aws_security_group_rule" "masters_kubelet_egress" {
  description = "Allow the cluster control plane to reach out workers kubelets and pods"
  from_port = 10250
  protocol = "tcp"
  security_group_id = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  to_port = 10250
  type = "egress"
}


# HTTPS traffic from the master nodes to workers kubelet and pods
resource "aws_security_group_rule" "masters_kubelet_https_egress" {
  description = "Allow the cluster control plane to reach out workers kubelets and pods https"
  from_port = 443
  protocol = "tcp"
  security_group_id = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  to_port = 443
  type = "egress"
}

# Traffic from the master nodes to all worker nodes
resource "aws_security_group_rule" "masters_workers_egress" {
  description = "Allow the cluster control plane to reach out all worker node security group"
  from_port = 1025
  to_port = 65535
  protocol = "tcp"
  security_group_id = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  type = "egress"
}
