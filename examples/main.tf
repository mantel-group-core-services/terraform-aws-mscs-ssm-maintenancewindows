terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
  default_tags {
    tags = {
      Owner      = "Mantel Group"
      DeployedBy = "Terraform"
    }
  }
}

module "patch_window_1" {
  source = "../"

  maintenance_window_name = "example-patch-window-1"
  schedule                = "cron(0 15 ? * TUE *)"
  duration                = 4
  cutoff                  = 1
  target_tag_key          = "Patch_Group"
  target_tag_value        = "Window1"
}

module "patch_window_2" {
  source = "../"

  maintenance_window_name = "example-patch-window-2"
  schedule                = "cron(0 15 ? * WED *)"
  duration                = 4
  cutoff                  = 1
  target_tag_key          = "Patch_Group"
  target_tag_value        = "Window2"
}

module "patch_window_with_baseline_override" {
  source = "../"

  maintenance_window_name = "example-patch-window-override"
  schedule                = "cron(0 15 ? * THU *)"
  duration                = 4
  cutoff                  = 1
  target_tag_key          = "Patch_Group"
  target_tag_value        = "Window_with_override"

  # These can be disabled
  update_cloudwatch_agent = false
  update_ssm_agent        = false

  # This Bucket exists in sandpit1 and is configured to not be nuked, it should be there if you need to inspect it.
  # The content of this baseline override can be found in ./example-patchbaseline-override.json
  baseline_override = "s3://example-bucket-for-patchbaseline-overrides-r9s-t1x-z2b3/example-patchbaseline-override.json"
}
