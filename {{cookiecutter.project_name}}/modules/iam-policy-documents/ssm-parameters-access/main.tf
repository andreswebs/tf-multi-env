data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  param_arn_prefix = "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter"
  param_arns       = [for p in var.parameter_names : "${local.param_arn_prefix}${p}"]
  param_path_arns  = [for p in var.parameter_names : "${local.param_arn_prefix}${p}/*"]
  param_arns_all   = concat(local.param_arns, local.param_path_arns)
  default_actions = [
    "ssm:GetParameter",
    "ssm:GetParameters",
    "ssm:GetParametersByPath",
    "ssm:GetParameterHistory",
  ]
  ssm_actions = concat(local.default_actions, var.additional_actions)
}

resource "random_id" "this" {
  byte_length = 8
}

data "aws_iam_policy_document" "this" {
  statement {
    sid       = random_id.this.hex
    actions   = local.ssm_actions
    resources = local.param_arns_all
  }
}
