resource "aws_vpc" "eks" {
  cidr_block = "${var.vpc_cidr}"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = [
    {
      key   = "Name"
      value = "eks"
    },
  ]

  #    {
  #      key   = "kubernetes.io/cluster/${aws_eks_cluster.example.name}"
  #      value = "shared"
  #    },
}

resource "aws_subnet" "public" {
  count = "${length(var.public_cidrs)}"

  vpc_id            = "${aws_vpc.eks.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.public_cidrs[count.index]}"

  tags = [
    {
      key   = "Name"
      value = "eks-public-${count.index}"
    },
  ]

  #    {
  #      key   = "kubernetes.io/cluster/${aws_eks_cluster.example.name}"
  #      value = "shared"
  #    },
}

resource "aws_subnet" "private" {
  count = "${length(var.private_cidrs)}"

  vpc_id     = "${aws_vpc.eks.id}"
  cidr_block = "${var.private_cidrs[count.index]}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = [
    {
      key   = "Name"
      value = "eks-private-${count.index}"
    },
  ]

  #    {
  #      key   = "kubernetes.io/cluster/${aws_eks_cluster.example.name}"
  #      value = "shared"
  #    },
}
