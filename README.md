# Provision a Kubernetes cluster on Amazon EKS using Terraform

## About the project

This project aims to show how to create a functional Kubernetes cluster on Amazon EKS with Terraform.

## Prerequisites

In order to check AWS configurations and the creation of resources and services we'll need to install the AWS client application (See the links section).

We can create a new AWS profile. I've named mine "sandbox".
If you already have an AWS profile created for other purposes, backup your ~/.aws/config and ~/.aws/credentials files.

```sh
mkdir ~/.aws
echo -e "[profile sandbox]\nregion = us-east-1\noutput = json" > ~/.aws/config
echo -e "[sandbox]\naws_access_key_id = AWS_ACCESS_KEY >\naws_secret_access_key = AWS_SECRET_KEY" > ~/.aws/credentials
```

If you prefer to create your infrastructure in a different region than "us-east-1", feel free to change it in the config file.
Replace "AWS_ACCESS_KEY" and AWS_SECRET_KEY with yours.

To check the profile is correctly configured execute the command:
```sh
aws configure --profile sandbox
```

Install the Terraform CLI application (see the links section).
Install the Kubectl Tool (see the links section).

## Installation

Create new backend and variables file from the template file existing in the files folder:
```sh
cp files/backend.tf .
cp files/variables.tf .
```

Generate a unique name for the S3 backend bucket used to store the Terraform state.
```sh
export TFSTATE_BUCKET="tfstate-sandbox-$(date +%s)"
echo $TFSTATE_BUCKET
```
You can create the S3 bucket using de AWS interactive dashboard or directly with an aws cli command:
```sh
aws s3api create-bucket --bucket $TFSTATE_BUCKET --region us-east-1 --profile sandbox
```

If we want to enable server-side encryption then execute:
```sh
aws s3api put-bucket-encryption --bucket $TFSTATE_BUCKET --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}' --profile sandbox
```

To check if the bucket is created execute the command:
```sh
aws s3api list-buckets --profile sandbox
```

Update the 'state_bucket' variable in the backend and variables.tf file.

```sh
cat backend.tf \
  | sed -e "s@state-bucket-value@$TFSTATE_BUCKET@g" \
  | tee backend.tf
```

Update the 'cluster_name' variable in the variables.tf file.
```sh
export CLUSTER_NAME="k8s-test-cluster"
echo $CLUSTER_NAME
cat variables.tf \
  | sed -e "s@cluster-name-value@$CLUSTER_NAME@g" \
  | tee variables.tf
```

Check the URL https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html for EKS Kubernetes versions.

Update the 'k8s_version' variable in the variables.tf file.
```sh
export K8S_VERSION="1.22"
echo $K8S_VERSION
cat variables.tf \
  | sed -e "s@k8s-version-value@$K8S_VERSION@g" \
  | tee variables.tf
```

Check the URL https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html for EKS Kubernetes versions.

Update the 'release_version' variable in the variables.tf file.

```sh
export RELEASE_VERSION="1.22.12-20221101"
echo $RELEASE_VERSION
cat variables.tf \
  | sed -e "s@release-version-value@$RELEASE_VERSION@g" \
  | tee variables.tf
```

To initialize the working directory containing Terraform configuration files execute the command: 
```sh
terraform init
```

If we are changing the Terraform state backend we will be prompted to execute:
```sh
terraform init -reconfigure
```

To validate our Terraform configuration files we can execute:
```sh
terraform validate
```

To create an execution plan, which lets us preview the changes that Terraform plans to make to our infrastructure, execute:
```sh
terraform plan
```

To apply the actions proposed in the execution plan execute:
```sh
terraform apply
```

Write "yes" when being asked for confirmation.

To check if the Kubernetes is up and running we'll have to update our local kubeconfig file with the EKS kubeconfig:
```sh
export KUBECONFIG=$PWD/kubeconfig
aws eks update-kubeconfig \
    --name \
    $(terraform output --raw cluster_name) \
    --region \
    $(terraform output --raw region) \
    --profile sandbox
```

Get nodes of the Kubernetes cluster:
```sh
kubectl get nodes
```

## Upgrade

Check initial Kubernetes version:
```sh
kubectl version --output yaml
```

Update the 'k8s_version' variable in the variables.tf file.
```sh
export K8S_VERSION="1.23"
echo $K8S_VERSION
cat variables.tf \
  | sed -e "s@k8s-version-value@$K8S_VERSION@g" \
  | tee variables.tf
```

Check the URL https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html for EKS Kubernetes versions.

Update the 'release_version' variable in the variables.tf file.

```sh
export RELEASE_VERSION="1.23.9-20221101"
echo $RELEASE_VERSION
cat variables.tf \
  | sed -e "s@release-version-value@$RELEASE_VERSION@g" \
  | tee variables.tf
```

Apply changes:
```sh
terraform apply
```

The K8s cluster will be destroyed and replaced by a new one with the specified version.

Check initial Kubernetes version:
```sh
kubectl version --output yaml
```

## Cleanup

To remove all insfrastructure created with terraform execute the command:
```sh
terraform destroy
```

## Links

* AWS Free Tier: https://aws.amazon.com/free
* Installing or updating the latest version of the AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
* Install Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli
* How to manage Terraform state: https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa
* Install Kubectl tool: https://kubernetes.io/docs/tasks/tools/
