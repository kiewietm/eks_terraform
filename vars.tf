variable "region" {
  default = "us-east-1"
}

variable "cross_acc_profile" {
  description = "AWS cli profile"
}

variable "cross_acc_role_arn" {
  description = "AWS cross account role arn (Valid value = \"\")"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "private_cidrs" {
  type = "list"

  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
  ]
}

variable "public_cidrs" {
  type = "list"

  default = [
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
}

variable "max_example_pods_per_node" {
  description = "Max Kobernetes 'example' pods on each node"
  default     = 10
}

variable "appname" {
  default = "example"
}

variable "environment" {
  default = "dev"
}

variable "asg_min_size" {
  description = "Min size for example asg"
  default     = 1
}

variable "asg_max_size" {
  description = "Max size of example asg"
  default     = 2
}

variable "asg_desired_size" {
  description = "Desired size of example asg"
  default     = 2
}

variable "instance_type" {
  description = "EC2 Instance type for example"
  default     = "t2.nano"
}

variable "instance_public_ip" {
  description = "Assign public IP to example nodes"
  default     = true
}

variable "ec2_key_name" {
  description = "Example nodes RSA key name"
  default     = "martin"
}
