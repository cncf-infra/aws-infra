// s3writer for artifacts management
resource "aws_iam_role" "artifacts-k8s-io-s3writer" {
  provider = aws.artifacts-k8s-io

  name = "artifacts.k8s.io_s3writer"
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
          AWS = "arn:aws:iam::585803375430:user/artifacts.k8s.io-ci"
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
            "container.googleapis.com/v1/projects/k8s-infra-prow-build-trusted/locations/us-central1/clusters/prow-build-trusted:sub" : "system:serviceaccount:test-pods:k8s-infra-promoter"
          }
        }
      }
    ]
  })

  max_session_duration = 43200

  tags = {
    project = "artifacts.k8s.io"
  }
}

resource "aws_iam_role_policy" "artifacts-k8s-io-s3writer-policy" {
  provider = aws.artifacts-k8s-io

  name = "artifacts.k8s.io_s3writer_policy"
  role = aws_iam_role.artifacts-k8s-io-s3writer.id

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
resource "aws_iam_role" "artifacts-k8s-io-s3admin" {
  provider = aws.artifacts-k8s-io

  name = "artifacts.k8s.io_s3admin"
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
    project = "artifacts.k8s.io"
  }
}

resource "aws_iam_role_policy" "artifacts-k8s-io-s3admin-policy" {
  provider = aws.artifacts-k8s-io

  name = "artifacts.k8s.io_s3admin_policy"
  role = aws_iam_role.artifacts-k8s-io-s3admin.id

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

resource "aws_iam_policy" "sts-allow-artifacts-k8s-io-s3writer" {
  provider = aws.k8s-infra-accounts

  name = "sts-allow-artifacts-k8s-io-s3writer"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "CallSTSAssumeRole",
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Resource" : "arn:aws:iam::513428760722:role/artifacts.k8s.io_s3writer"
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
resource "aws_iam_user" "artifacts-k8s-io-ci" {
  provider = aws.k8s-infra-accounts
  name     = "artifacts.k8s.io-ci"
}
resource "aws_iam_user_policy_attachment" "sts-allow-artifacts-k8s-io-s3writer" {
  provider   = aws.k8s-infra-accounts
  user       = aws_iam_user.artifacts-k8s-io-ci.name
  policy_arn = aws_iam_policy.sts-allow-artifacts-k8s-io-s3writer.arn
}

resource "aws_iam_openid_connect_provider" "k8s-infra-trusted-cluster" {
  provider = aws.artifacts-k8s-io

  url             = "https://container.googleapis.com/v1/projects/k8s-infra-prow-build-trusted/locations/us-central1/clusters/prow-build-trusted"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["08745487e891c19e3078c1f2a07e452950ef36f6"]
}
