# ssm-maintenance-windows

This module is used to deploy a single SSM Maintenance Window with sensible defaults. It can be deployed any number of times into an AWS Account in order to achieve patching of EC2 Instances.

## For Contributors

This repository has `pre-commit` hooks so installing `pre-commit` is required. Instructions can be found here: https://pre-commit.com/

## PatchBaseline Overrides

This module has support for *using* a Baseline Override in Patch Manager, but the act of *creating* a Baseline Override is beyond the scope of Core Services. It can become quite complex and its not something that want to create using the Core Services pattern. That said, we do want to support it if the customer needs it.

If Baseline Overrides are required, you should break that work out into its own project or task.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_resourcegroups_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/resourcegroups_group) | resource |
| [aws_ssm_document.dnf_releasever](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document) | resource |
| [aws_ssm_maintenance_window.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window) | resource |
| [aws_ssm_maintenance_window_target.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_target) | resource |
| [aws_ssm_maintenance_window_task.dnf_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |
| [aws_ssm_maintenance_window_task.install_os_patches](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |
| [aws_ssm_maintenance_window_task.scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |
| [aws_ssm_maintenance_window_task.update_cloudwatch_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |
| [aws_ssm_maintenance_window_task.update_ssm_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_baseline_override"></a> [baseline\_override](#input\_baseline\_override) | Optional - S3 URI pointing to a BaselineOverride object. Don't use this if you don't need it.<br/>    Using this is suitable for customers who require the use of multiple Patchbaseline Documents for the same Operating Systems.<br/>    This PatchBaseline Override must already exist when you supply this variable, this is currently a manual step.<br/>    See:https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-baselineoverride-parameter.html | `string` | `null` | no |
| <a name="input_cutoff"></a> [cutoff](#input\_cutoff) | The number of hours before the end of the Maintenance Window that Systems Manager stops scheduling new tasks for execution. | `number` | `1` | no |
| <a name="input_dnf_releasever_override"></a> [dnf\_releasever\_override](#input\_dnf\_releasever\_override) | Set this to the dnf release you want to pin to.  The default ('latest') is recommended for long-term patch compliance.  Will do nothing on instances which aren't Amazon Linux 2023 and instances which already have /etc/dnf/vars/releasever present. | `string` | `"latest"` | no |
| <a name="input_duration_hours"></a> [duration\_hours](#input\_duration\_hours) | The max duration of the Maintenance Window in hours. Default is 4hrs. | `number` | `4` | no |
| <a name="input_maintenance_window_name"></a> [maintenance\_window\_name](#input\_maintenance\_window\_name) | The name of the SSM Maintenance Window | `string` | n/a | yes |
| <a name="input_max_concurrency"></a> [max\_concurrency](#input\_max\_concurrency) | How many hosts should commands run on at a time. This number should be as high as realistically possible | `number` | `10` | no |
| <a name="input_max_errors"></a> [max\_errors](#input\_max\_errors) | How many errors should a command fail on before cancelling the Maintenance Window. | `number` | `10` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | An AWS Cron expression for the Maintenance Window. See https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-scheduled-rule-pattern.html | `string` | n/a | yes |
| <a name="input_target_tag_key"></a> [target\_tag\_key](#input\_target\_tag\_key) | The Key for the EC2 Instance Tag that is used to target resources for the Maintenance Window.<br/>It should always be left at the default, per AWS recommendations:<br/>https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-patch-groups.html#how-it-works-patch-groups | `string` | `"PatchGroup"` | no |
| <a name="input_target_tag_value"></a> [target\_tag\_value](#input\_target\_tag\_value) | The value for the EC2 Instance Tag that is used to target resources for the Maintenance Window | `string` | n/a | yes |
| <a name="input_update_cloudwatch_agent"></a> [update\_cloudwatch\_agent](#input\_update\_cloudwatch\_agent) | Determines whether to include a stage in the Maintenance Window config to update the CloudWatch Agent.<br/>    Recommended to leave this enabled unless there is a good reason not to. | `bool` | `true` | no |
| <a name="input_update_ssm_agent"></a> [update\_ssm\_agent](#input\_update\_ssm\_agent) | Determines whether to include a stage in the Maintenance Window config to update the SSM Agent.<br/>    Recommended to leave this on and only turn it off if something like CarbonBlack is blocking the agent update. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_maintenance_window_target"></a> [maintenance\_window\_target](#output\_maintenance\_window\_target) | The id of the SSM maintenance window target |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The id of the resource group that is used as the target for the maintenance window |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group that is used as the target for the maintenance window |
<!-- END_TF_DOCS -->
