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
          AWS = "arn:aws:iam::585803375430:user/registry.k8s.io-ci"
        }
      },
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
          "s3:ListAllMyBuckets",
          "s3:*Object",
          "s3:ListBucket"
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
