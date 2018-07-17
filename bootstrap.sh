#!/bin/bash

#Download EKS Supported AWS CLI
#Must be 1.15.47 or higher
curl -o awscli.tar.gz https://github.com/aws/aws-cli/archive/1.15.49.tar.gz

#Get EKS Configured Kubectl
curl -o eks https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/linux/amd64/kubectl
curl -o eks.md5 https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/linux/amd64/kubectl.md5

#local kubelet config
#https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
export KUBECONFIG=$KUBECONFIG:~/.kube/config-devel

#Get Heptio Auth
curl -o heptio-authenticator-aws https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/linux/amd64/heptio-authenticator-aws
chmod +x ./heptio-authenticator-aws
export PATH=$PWD:$PATH

#Get AWS Auth Config Mat
#curl -o aws-auth-conf.yaml https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/aws-auth-cm.yaml

#EKS Worker AMI
#aws ec2 describe-images --image-ids ami-dea4d5a1 --region us-east-1

#Auth worker nodes
#kubectl apply -f aws-auth-cm.yaml
