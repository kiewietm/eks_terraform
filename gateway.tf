resource "aws_internet_gateway" "eks" {
  vpc_id = "${aws_vpc.eks.id}"

  tags {
    Name = "eks"
  }
}

resource "aws_eip" "nat" {
  vpc        = true
  depends_on = ["aws_internet_gateway.eks"]

  tags {
    Name = "eks"
  }
}

resource "aws_nat_gateway" "eks" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.*.id[0]}"

  tags {
    Name = "eks"
  }
}
