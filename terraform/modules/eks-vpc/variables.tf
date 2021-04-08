# VPC CIDR block
variable "eks_vpc_block" {
  type = string
}

# Private subnet prefixes
variable "eks_private_subnets_prefix_list" {
  type = list(string)
}

# Public subnet prefixes
variable "eks_public_subnets_prefix_list" {
  type = list(string)
}

# Cluster name prefix
variable "clusters_name_prefix" {
  type = string
}

# Commong tags to assign to any of the VPC resources to help identify them
variable "common_tags" {
  type = map(string)
}
