resource "aws_security_group" "eks" {
  name        = "eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.eks.id}"

  tags = [
    {
      key   = "Name"
      value = "eks-cluster"
    },
  ]

  #    {
  #      key   = "kubernetes.io/cluster/${aws_eks_cluster.example.name}"
  #      value = "owned"
  #    },
}

resource "aws_security_group" "node" {
  name        = "eks-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.eks.id}"

  tags = [
    {
      key   = "Name"
      value = "eks-node"
    },
    {
      key   = "kubernetes.io/cluster/${aws_eks_cluster.example.name}"
      value = "owned"
    },
  ]
}

resource "aws_security_group_rule" "inter_node" {
  type                     = "ingress"
  description              = "Allow node to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${aws_security_group.node.id}"
}

resource "aws_security_group_rule" "cluster_control" {
  type                     = "ingress"
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${aws_security_group.eks.id}"
}

resource "aws_security_group_rule" "cluster_node" {
  type                     = "egress"
  description              = "Allow the cluster control plane to communicate with worker Kubelet and pods"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks.id}"
  source_security_group_id = "${aws_security_group.node.id}"
}

resource "aws_security_group_rule" "cluster_api" {
  type                     = "ingress"
  description              = "Allow nodes to communicate with the cluster API Server"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks.id}"
  source_security_group_id = "${aws_security_group.node.id}"
}

resource "aws_security_group_rule" "node_world" {
  type              = "egress"
  description       = "Allow node egress to world"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = "${aws_security_group.node.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}
