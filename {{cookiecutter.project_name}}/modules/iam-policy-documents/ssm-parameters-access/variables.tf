variable "parameter_names" {
  type        = list(string)
  description = "List of names of the allowed SSM parameters"
}

variable "additional_actions" {
  type        = list(string)
  description = "List of additional policy actions for the allowed secrets. Default is empty"
  default     = []
}
