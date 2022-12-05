// s3writer for content management
resource "aws_iam_role" "registry-k8s-io-s3writer" {
  provider = aws.registry-k8s-io

  name = "registry.k8s.io_s3writer"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::768319786644:root"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "batchoperations.s3.amazonaws.com"
        },
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::585803375430:user/registry.k8s.io-ci"
        }
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : aws_iam_openid_connect_provider.k8s-infra-trusted-cluster.arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "container.googleapis.com/v1/projects/k8s-infra-prow-build-trusted/locations/us-central1/clusters/prow-build-trusted:sub" : "system:serviceaccount:test-pods:s3-sync"
          }
        }
      }
    ]
  })

  max_session_duration = 43200

  tags = {
    project = "registry.k8s.io"
  }
}

resource "aws_iam_role_policy" "registry-k8s-io-s3writer-policy" {
  provider = aws.registry-k8s-io

  name = "registry.k8s.io_s3writer_policy"
  role = aws_iam_role.registry-k8s-io-s3writer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*Object",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionTagging",
          "s3:GetReplicationConfiguration",
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "s3:PutReplicationConfiguration",
          "s3:ReplicateObject",
          "s3:ReplicateTags"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

// s3admin for bucket management
resource "aws_iam_role" "registry-k8s-io-s3admin" {
  provider = aws.registry-k8s-io

  name = "registry.k8s.io_s3admin"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::768319786644:root"
        }
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "batchoperations.s3.amazonaws.com"
        },
      },
    ]
  })

  max_session_duration = 43200

  tags = {
    project = "registry.k8s.io"
  }
}

resource "aws_iam_role_policy" "registry-k8s-io-s3admin-policy" {
  provider = aws.registry-k8s-io

  name = "registry.k8s.io_s3admin_policy"
  role = aws_iam_role.registry-k8s-io-s3admin.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
          "s3-object-lambda:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "sts-allow-registry-k8s-io-s3writer" {
  provider = aws.k8s-infra-accounts

  name = "sts-allow-registry-k8s-io-s3writer"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "CallSTSAssumeRole",
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Resource" : "arn:aws:iam::513428760722:role/registry.k8s.io_s3writer"
      },
      {
        "Sid" : "GetTokens",
        "Effect" : "Allow",
        "Action" : [
          "sts:GetSessionToken",
          "sts:GetAccessKeyInfo",
          "sts:GetCallerIdentity",
          "sts:GetServiceBearerToken"
        ],
        "Resource" : "*"
      }
    ]
  })
}
resource "aws_iam_user" "registry-k8s-io-ci" {
  provider = aws.k8s-infra-accounts
  name     = "registry.k8s.io-ci"
}
resource "aws_iam_user_policy_attachment" "sts-allow-registry-k8s-io-s3writer" {
  provider   = aws.k8s-infra-accounts
  user       = aws_iam_user.registry-k8s-io-ci.name
  policy_arn = aws_iam_policy.sts-allow-registry-k8s-io-s3writer.arn
}

resource "aws_iam_openid_connect_provider" "k8s-infra-trusted-cluster" {
  provider = aws.registry-k8s-io

  url             = "https://container.googleapis.com/v1/projects/k8s-infra-prow-build-trusted/locations/us-central1/clusters/prow-build-trusted"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["08745487e891c19e3078c1f2a07e452950ef36f6"]
}

resource "aws_iam_openid_connect_provider" "github" {
  provider = aws.apisnoop

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_user" "verify-conformance-ci" {
  provider = aws.apisnoop
  name     = "verify-conformance-ci"
}

resource "aws_iam_role" "verify-conformance-ci" {
  provider = aws.apisnoop

  name = "verify-conformance-ci"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::928655657136:user/verify-conformance-ci"
        }
      },
      {
        Action = "sts:TagSession"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::928655657136:user/verify-conformance-ci"
        }
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::928655657136:oidc-provider/token.actions.githubusercontent.com"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : "repo:cncf-infra/verify-conformance:*"
          },
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  max_session_duration = 3600

  tags = {
    project = "registry.k8s.io"
  }
}

resource "aws_iam_role_policy" "verify-conformance-ci-policy" {
  provider = aws.apisnoop

  name = "verify-conformance-ci_policy"
  role = aws_iam_role.verify-conformance-ci.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:AccessKubernetesApi"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:eks:ap-southeast-2:928655657136:cluster/prow-cncf-io-eks"
      },
      {
        Action = [
          "eks:ListClusters"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:eks:ap-southeast-2:928655657136:cluster/*"
      },
    ]
  })
}
