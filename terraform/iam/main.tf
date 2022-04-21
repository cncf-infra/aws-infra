resource "aws_iam_role" "registry-k8s-io-s3writer" {
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
    ]
  })

  tags = {
    project = "registry.k8s.io"
  }
}


resource "aws_iam_role_policy" "registry-k8s-io-s3writer-policy" {
  name = "registry.k8s.io_s3writer_policy"
  role = aws_iam_role.registry-k8s-io-s3writer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
          "s3-object-lambda:*"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3::266690972299:*"
      },
    ]
  })
}
