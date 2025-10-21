################################################################################
# Resource Group outputs
################################################################################

output "resource_group_id" {
  description = "The id of the resource group that is used as the target for the maintenance window"
  value       = aws_resourcegroups_group.main.id
}
output "resource_group_name" {
  description = "The name of the resource group that is used as the target for the maintenance window"
  value       = aws_resourcegroups_group.main.name
}

################################################################################
# Maintenance Window Target
################################################################################

output "maintenance_window_target" {
  description = "The id of the SSM maintenance window target"
  value       = aws_ssm_maintenance_window_target.main.id
}
