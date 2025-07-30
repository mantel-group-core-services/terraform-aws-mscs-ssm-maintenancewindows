################################################################################
# Resource Group outputs
################################################################################
output "resource_group_id" {
  description = "The ID of the Resource Group that is used as the target for the Maitenance Windows"
  value       = aws_resourcegroups_group.main.id
}
output "resource_group_name" {
  description = "The name of the Resource Group that is used as the target for the Maitenance Windows"
  value       = aws_resourcegroups_group.main.name
}

################################################################################
# Maintenance Window Target
################################################################################
output "maintenance_window_target" {
  description = "The ID of the SSM Maintenance Window Target"
  value       = aws_ssm_maintenance_window_target.main.id
}
