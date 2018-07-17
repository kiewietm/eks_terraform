resource "aws_eks_cluster" "example" {
  name     = "example-eks"
  role_arn = "${aws_iam_role.eks.arn}"

  vpc_config {
    subnet_ids         = ["${aws_subnet.private.*.id}", "${aws_subnet.public.*.id}"]
    security_group_ids = ["${aws_security_group.eks.id}"]
  }
}
