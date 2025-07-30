// Maintenance Windows variables

variable "baseline_override" {
  type        = string
  description = <<EOF
    Optional - S3 URI pointing to a BaselineOverride object. Don't use this if you don't need it.
    Using this is suitable for customers who require the use of multiple Patchbaseline Documents for the same Operating Systems.
    This PatchBaseline Override must already exist when you supply this variable, this is currently a manual step.
    See:https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-baselineoverride-parameter.html
    EOF
  default     = null
}

variable "cutoff" {
  type        = number
  description = "The number of hours before the end of the Maintenance Window that Systems Manager stops scheduling new tasks for execution."
  default     = 1
}

variable "duration_hours" {
  type        = number
  description = "The max duration of the Maintenance Window in hours. Default is 4hrs."
  default     = 4
}

variable "maintenance_window_name" {
  type        = string
  description = "The name of the SSM Maintenance Window"
}

variable "max_concurrency" {
  type        = number
  description = "How many hosts should commands run on at a time. This number should be as high as realistically possible"
  default     = 10
}

variable "max_errors" {
  type        = number
  description = "How many errors should a command fail on before cancelling the Maintenance Window."
  default     = 10
}

variable "schedule" {
  type        = string
  description = "An AWS Cron expression for the Maintenance Window. See https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-scheduled-rule-pattern.html"
}

variable "target_tag_key" {
  type        = string
  description = "The Key for the EC2 Instance Tag that is used to target resources for the Maintenance Window"
}

variable "target_tag_value" {
  type        = string
  description = "The value for the EC2 Instance Tag that is used to target resources for the Maintenance Window"
}

variable "update_cloudwatch_agent" {
  type        = bool
  description = <<EOF
    Determines whether to include a stage in the Maintenance Window config to update the CloudWatch Agent.
    Recommended to leave this enabled unless there is a good reason not to.
    EOF
  default     = true
}

variable "update_ssm_agent" {
  type        = bool
  description = <<EOF
    Determines whether to include a stage in the Maintenance Window config to update the SSM Agent.
    Recommended to leave this on and only turn it off if something like CarbonBlack is blocking the agent update.
    EOF
  default     = true
}
