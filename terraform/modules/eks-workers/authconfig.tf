# This defines a yaml file that will be used to register and authenticate new worker nodes in the cluster
locals {
  authconfig = <<AUTHCONFIG
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: "${aws_iam_role.workers.arn}"
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
AUTHCONFIG
}
