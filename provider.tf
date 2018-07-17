provider "aws" {
  region  = "${var.region}"
  profile = "${var.cross_acc_profile}"

  assume_role {
    role_arn     = "${var.cross_acc_role_arn}"
    session_name = "EKS-Cluster"
  }
}
