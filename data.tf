data "aws_availability_zones" "available" {}

data "aws_ami" "eks" {
  most_recent = true

  filter {
    name   = "name"
    values = ["eks-worker-*"]
  }
}

data "template_file" "kubelet_auth" {
  template = "${file("./aws-auth-conf.tmpl")}"

  vars {
    #Instance_Role_Arn = "${aws_iam_instance_profile.node.arn}"
    Instance_Role_Arn = "${aws_iam_role.instance.arn}"
  }

  #provisioner "file" {
  #  content     = "${self.rendered}"
  #  destination = "./aws-auth-conf.out"
  #}
}

resource "null_resource" "kubelet_auth" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.kubelet_auth.rendered}' > ./aws-auth-conf.out"
  }

  #provisioner "file" {
  #    content     = "${data.template_file.kops.rendered}"
  #    destination = "./kops.sh"
  #}
}

data "template_file" "kubelet_conf" {
  template = "${file("./kube-config.tmpl")}"

  vars {
    EKS_Cluster_Endpoint = "${aws_eks_cluster.example.endpoint}"
    EKS_Cluster_Cert     = "${aws_eks_cluster.example.certificate_authority.0.data}"
    EKS_Cluster_Name     = "${aws_eks_cluster.example.name}"
    Cross_Acc_Role_Arn   = "${var.cross_acc_role_arn}"
    Cross_Acc_Profile    = "${var.cross_acc_profile}"
  }

  #provisioner "file" {
  #  content     = "${self.rendered}"
  #  destination = "./kube-config.out"
  #}
}

resource "null_resource" "kubelet_conf" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.kubelet_conf.rendered}' > ./kube-config.out"
  }

  #provisioner "file" {
  #    content     = "${data.template_file.kops.rendered}"
  #    destination = "./kops.sh"
  #}
}
