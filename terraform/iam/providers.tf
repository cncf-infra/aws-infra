terraform {
  backend "s3" {
    bucket = "cncf-io-iam-tfstate"
    key    = "terraform.tfstate"
    region = "ap-southeast-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

provider "aws" {
  alias = "registry-k8s-io"

  region = "us-west-1"

  # Jay, Hippie and Caleb are cool
  assume_role {
    # deleting this role causes bad things. You just really don't want this. Count this as a WARNING!
    # also! the account (513428760722) is CNCF/Kubernetes/registry.k8s.io/registry.k8s.io_admin / k8s-infra-aws-registry-k8s-io-admin@kubernetes.io
    role_arn = "arn:aws:iam::513428760722:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias = "k8s-infra-accounts"

  region = "us-west-1"

  assume_role {
    # deleting this role causes bad things. You just really don't want this. Count this as a WARNING!
    # also! the account (585803375430) is CNCF/Kubernetes/k8s-infra-accounts / k8s-infra-accounts@kubernetes.io
    role_arn = "arn:aws:iam::585803375430:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias = "apisnoop"

  region = "us-west-1"

  assume_role {
    # deleting this role causes bad things. You just really don't want this. Count this as a WARNING!
    # also! the account (928655657136) is CNCF/APISnoop / cncf-aws-admins@lists.cncf.io
    role_arn = "arn:aws:iam::928655657136:role/OrganizationAccountAccessRole"
  }
}
