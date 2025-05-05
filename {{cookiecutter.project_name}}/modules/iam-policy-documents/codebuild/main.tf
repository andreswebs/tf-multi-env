data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
  dns_suffix = data.aws_partition.current.dns_suffix
}

locals {
  log_group_arn              = "arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:${var.log_group_name_prefix}"
  s3_bucket_arn              = "arn:${local.partition}:s3:::codepipeline-${local.region}-*"
  codebuild_report_group_arn = "arn:${local.partition}:codebuild:${local.region}:${local.account_id}:report-group/*"
  codestar_connections_arn   = "arn:${local.partition}:codestar-connections:${local.region}:${local.account_id}:connection/*"
  codeconnections_arn        = "arn:${local.partition}:codeconnections:${local.region}:${local.account_id}:connection/*"
  network_interface_arn      = "arn:${local.partition}:ec2:${local.region}:${local.account_id}:network-interface/*"
  subnet_arn                 = "arn:${local.partition}:ec2:${local.region}:${local.account_id}:subnet/*"
}

data "aws_iam_policy_document" "logs" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      local.log_group_arn,
      "${local.log_group_arn}:*"
    ]
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    resources = [
      "${local.s3_bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
    ]
    resources = [
      local.s3_bucket_arn
    ]
  }
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages",
    ]
    resources = [
      local.codebuild_report_group_arn
    ]
  }
}

data "aws_iam_policy_document" "connections" {
  statement {
    actions = [
      "codestar-connections:GetConnectionToken",
      "codestar-connections:GetConnection",
      "codeconnections:GetConnectionToken",
      "codeconnections:GetConnection",
      "codeconnections:UseConnection",
    ]
    resources = [
      local.codestar_connections_arn,
      local.codeconnections_arn,
    ]
  }
}

data "aws_iam_policy_document" "network" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ec2:CreateNetworkInterfacePermission",
    ]
    resources = [
      local.network_interface_arn
    ]
    condition {
      test     = "StringLike"
      variable = "ec2:Subnet"
      values   = [local.subnet_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.${local.dns_suffix}"]
    }

  }
}

data "aws_iam_policy_document" "this" {
  source_policy_documents = [
    data.aws_iam_policy_document.logs.json,
    data.aws_iam_policy_document.s3.json,
    data.aws_iam_policy_document.codebuild.json,
    data.aws_iam_policy_document.connections.json,
    data.aws_iam_policy_document.network.json,
  ]
}

