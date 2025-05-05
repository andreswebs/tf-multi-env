output "json" {
  value       = data.aws_iam_policy_document.this.json
  description = "The IAM Policy document JSON contents"
}

output "parameter_arns" {
  value       = local.param_arns_all
  description = "List of allowed parameter ARNs"
}

output "parameter_names" {
  value       = var.parameter_names
  description = "List of names of the allowed SSM parameters"
}

output "additional_actions" {
  value       = var.additional_actions
  description = "List of additional policy actions for the allowed secrets"
}
