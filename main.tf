resource "aws_resourcegroups_group" "main" {
  name = var.maintenance_window_name

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::EC2::Instance"
  ],
  "TagFilters": [
    {
      "Key": "${var.target_tag_key}",
      "Values": ["${var.target_tag_value}"]
    }
  ]
}
JSON
  }
}

resource "aws_ssm_document" "dnf_releasever" {
  document_format = "YAML"
  document_type   = "Command"
  name            = "${var.maintenance_window_name}-configure-dnf"

  content = <<-EOF
    schemaVersion: '2.2'
    description: Configure dnf to use --releasever=${var.dnf_releasever_override}
    mainSteps:
      - action: aws:runShellScript
        name: configureDnf
        inputs:
          runCommand:
            - |
              if command -v dnf &> /dev/null && \
                  test "$(awk -F\" '/^PLATFORM_ID=/ {print $2}' /etc/os-release)" = "platform:al2023" && \
                  ! test -e /etc/dnf/vars/releasever; then
                echo "${var.dnf_releasever_override}" > /etc/dnf/vars/releasever
                chmod 644 /etc/dnf/vars/releasever
              fi
  EOF
}

resource "aws_ssm_maintenance_window" "main" {
  name                       = var.maintenance_window_name
  schedule                   = var.schedule
  duration                   = var.duration_hours
  cutoff                     = var.cutoff
  allow_unassociated_targets = true
}

resource "aws_ssm_maintenance_window_target" "main" {
  window_id     = aws_ssm_maintenance_window.main.id
  resource_type = "RESOURCE_GROUP"
  targets {
    key    = "resource-groups:Name"
    values = [aws_resourcegroups_group.main.name]
  }
}

resource "aws_ssm_maintenance_window_task" "dnf_config" {
  max_concurrency = var.max_concurrency
  max_errors      = var.max_errors
  name            = "${var.maintenance_window_name}-configure-dnf"
  priority        = 5
  task_arn        = aws_ssm_document.dnf_releasever.arn
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.main.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.main.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      timeout_seconds = 60
    }
  }
}

resource "aws_ssm_maintenance_window_task" "install_os_patches" {
  window_id       = aws_ssm_maintenance_window.main.id
  name            = "${var.maintenance_window_name}-install-patches"
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  max_concurrency = var.max_concurrency
  max_errors      = var.max_errors
  priority        = 10

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.main.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      parameter {
        name   = "RebootOption"
        values = ["RebootIfNeeded"]
      }
      dynamic "parameter" {
        for_each = var.baseline_override != null ? [1] : []
        content {
          name   = "BaselineOverride"
          values = [var.baseline_override]
        }
      }
    }
  }
}

resource "aws_ssm_maintenance_window_task" "scan" {
  window_id       = aws_ssm_maintenance_window.main.id
  name            = "${var.maintenance_window_name}-reporting-scan"
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  max_concurrency = var.max_concurrency
  max_errors      = var.max_errors
  priority        = 20

  targets {
    key    = "WindowTargetIds"
    values = ["${aws_ssm_maintenance_window_target.main.id}"]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "Operation"
        values = ["Scan"]
      }
      parameter {
        name   = "RebootOption"
        values = ["NoReboot"]
      }
      dynamic "parameter" {
        for_each = var.baseline_override != null ? [1] : []
        content {
          name   = "BaselineOverride"
          values = [var.baseline_override]
        }
      }
    }
  }
}

resource "aws_ssm_maintenance_window_task" "update_ssm_agent" {
  count = var.update_ssm_agent ? 1 : 0

  window_id       = aws_ssm_maintenance_window.main.id
  name            = "${var.maintenance_window_name}-updateSSM"
  task_arn        = "AWS-UpdateSSMAgent"
  task_type       = "RUN_COMMAND"
  max_concurrency = var.max_concurrency
  max_errors      = var.max_errors
  priority        = 30

  targets {
    key    = "WindowTargetIds"
    values = ["${aws_ssm_maintenance_window_target.main.id}"]
  }
}

resource "aws_ssm_maintenance_window_task" "update_cloudwatch_agent" {
  count = var.update_cloudwatch_agent ? 1 : 0

  window_id       = aws_ssm_maintenance_window.main.id
  name            = "${var.maintenance_window_name}-updateSSM"
  task_arn        = "AWS-ConfigureAWSPackage"
  task_type       = "RUN_COMMAND"
  max_concurrency = var.max_concurrency
  max_errors      = var.max_errors
  priority        = 40

  targets {
    key    = "WindowTargetIds"
    values = ["${aws_ssm_maintenance_window_target.main.id}"]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "action"
        values = ["Install"]
      }
      parameter {
        name   = "name"
        values = ["AmazonCloudWatchAgent"]
      }
      parameter {
        name   = "version"
        values = ["latest"]
      }
    }
  }
}
