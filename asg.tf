resource "aws_autoscaling_group" "ecs_cluster" {
  name                 = "${var.appname}_${var.environment}"
  vpc_zone_identifier  = ["${aws_subnet.private.*.id}"]
  min_size             = "${var.asg_min_size}"
  max_size             = "${var.asg_max_size}"
  desired_capacity     = "${var.asg_desired_size}"
  launch_configuration = "${aws_launch_configuration.ecs_cluster.name}"
  health_check_type    = "EC2"

  tags = [
    {
      key                 = "Name"
      value               = "${var.appname}_${var.environment}"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${aws_eks_cluster.example.name}"
      value               = "owned"
      propagate_at_launch = true
    },
  ]
}

resource "aws_launch_configuration" "ecs_cluster" {
  name                        = "${aws_eks_cluster.example.name}-eks-nodes"
  instance_type               = "${var.instance_type}"
  image_id                    = "${data.aws_ami.eks.image_id}"
  iam_instance_profile        = "${aws_iam_instance_profile.node.id}"
  associate_public_ip_address = "${var.instance_public_ip}"

  security_groups             = ["${aws_security_group.node.id}"]
  associate_public_ip_address = "${var.instance_public_ip}"
  key_name                    = "${var.ec2_key_name}"

  #Source: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
  user_data = "${join("", list(
                    "#!/bin/bash -xe\n",
                    "CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki", "\n",
                    "CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt", "\n",
                    "MODEL_DIRECTORY_PATH=~/.aws/eks", "\n",
                    "MODEL_FILE_PATH=$MODEL_DIRECTORY_PATH/eks-2017-11-01.normal.json", "\n",
                    "mkdir -p $CA_CERTIFICATE_DIRECTORY", "\n",
                    "mkdir -p $MODEL_DIRECTORY_PATH", "\n",
                    "curl -o $MODEL_FILE_PATH https://s3-us-west-2.amazonaws.com/amazon-eks/1.10.3/2018-06-05/eks-2017-11-01.normal.json", "\n",
                    "aws configure add-model --service-model file://$MODEL_FILE_PATH --service-name eks", "\n",
                    "aws eks describe-cluster --region=", "${var.region}"," --name=", "${aws_eks_cluster.example.name}"," --query 'cluster.{certificateAuthorityData: certificateAuthority.data, endpoint: endpoint}' > /tmp/describe_cluster_result.json", "\n",
                    "cat /tmp/describe_cluster_result.json | grep certificateAuthorityData | awk '{print $2}' | sed 's/[,\"]//g' | base64 -d >  $CA_CERTIFICATE_FILE_PATH", "\n",
                    "MASTER_ENDPOINT=$(cat /tmp/describe_cluster_result.json | grep endpoint | awk '{print $2}' | sed 's/[,\"]//g')", "\n",
                    "INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)", "\n",
                    "sed -i s,MASTER_ENDPOINT,$MASTER_ENDPOINT,g /var/lib/kubelet/kubeconfig", "\n",
                    "sed -i s,CLUSTER_NAME,", "${aws_eks_cluster.example.name}", ",g /var/lib/kubelet/kubeconfig", "\n",
                    "sed -i s,REGION,","${var.region}", ",g /etc/systemd/system/kubelet.service", "\n",
                    "sed -i s,MAX_PODS,", "${var.max_example_pods_per_node}", ",g /etc/systemd/system/kubelet.service", "\n",
                    "sed -i s,MASTER_ENDPOINT,$MASTER_ENDPOINT,g /etc/systemd/system/kubelet.service", "\n",
                    "sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service", "\n",
                    "DNS_CLUSTER_IP=10.100.0.10", "\n",
                    "if [[ $INTERNAL_IP == 10.* ]] ; then DNS_CLUSTER_IP=172.20.0.10; fi", "\n",
                    "sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g  /etc/systemd/system/kubelet.service", "\n",
                    "sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig" , "\n",
                    "sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g  /etc/systemd/system/kubelet.service" , "\n",
                    "systemctl daemon-reload", "\n",
                    "systemctl restart kubelet", "\n",
              ))}"
}
