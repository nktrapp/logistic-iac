locals {
  log_group_name = "/ecs/${var.project_name}/${var.environment}/${var.service_name}"
  app_cpu        = var.cpu
  app_memory     = var.memory
  task_cpu       = var.enable_adot_xray ? var.cpu + var.adot_cpu : var.cpu
  task_memory    = var.enable_adot_xray ? var.memory + var.adot_memory : var.memory
  adot_name      = "adot-collector"

  adot_collector_config = <<-YAML
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
processors:
  memory_limiter:
    check_interval: 1s
    limit_mib: ${var.adot_memory_limiter_mib}
    spike_limit_mib: ${var.adot_memory_limiter_spike_mib}
  batch:
    timeout: 5s
    send_batch_size: 50
exporters:
  awsxray:
    region: ${var.aws_region}
service:
  telemetry:
    logs:
      level: warn
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [awsxray]
YAML

  environment = [
    for key in sort(keys(var.environment_variables)) : {
      name  = key
      value = var.environment_variables[key]
    }
  ]

  secrets = [
    for key in sort(keys(var.secrets)) : {
      name      = key
      valueFrom = var.secrets[key]
    }
  ]

  repository_credentials = var.image_pull_secret_arn == "" ? {} : {
    repositoryCredentials = {
      credentialsParameter = var.image_pull_secret_arn
    }
  }

  adot_container = {
    name              = local.adot_name
    image             = var.adot_image
    cpu               = var.adot_cpu
    memory            = var.adot_memory
    memoryReservation = var.adot_memory_reservation
    essential         = false
    portMappings = [
      {
        containerPort = 4317
        hostPort      = 0
        protocol      = "tcp"
      },
      {
        containerPort = 4318
        hostPort      = 0
        protocol      = "tcp"
      }
    ]
    environment = [
      {
        name  = "AWS_REGION"
        value = var.aws_region
      },
      {
        name  = "AOT_CONFIG_CONTENT"
        value = local.adot_collector_config
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.service.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "adot"
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "service" {
  name              = local.log_group_name
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-${var.service_name}-logs"
    Layer   = "service"
    Service = var.service_name
  })
}

resource "aws_lb_target_group" "service" {
  name        = var.target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  deregistration_delay = var.deregistration_delay_seconds

  health_check {
    path                = var.health_check_path
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = merge(var.tags, {
    Name    = var.target_group_name
    Layer   = "service"
    Service = var.service_name
  })
}

resource "aws_lb_listener_rule" "service" {
  listener_arn = var.alb_listener_arn
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service.arn
  }

  condition {
    path_pattern {
      values = var.path_patterns
    }
  }

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-${var.service_name}-listener-rule"
    Layer   = "service"
    Service = var.service_name
  })
}

resource "aws_iam_role" "task_execution" {
  name = "${var.name_prefix}-${var.service_name}-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-${var.service_name}-exec"
    Layer   = "service"
    Service = var.service_name
  })
}

resource "aws_iam_role_policy_attachment" "task_execution_base" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "task_execution_secrets" {
  count = length(var.secret_arns) + (var.image_pull_secret_arn == "" ? 0 : 1) > 0 ? 1 : 0

  name = "${var.name_prefix}-${var.service_name}-secret-access"
  role = aws_iam_role.task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = concat(var.secret_arns, var.image_pull_secret_arn == "" ? [] : [var.image_pull_secret_arn])
    }]
  })
}

resource "aws_iam_role" "task" {
  name = "${var.name_prefix}-${var.service_name}-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-${var.service_name}-task"
    Layer   = "service"
    Service = var.service_name
  })
}

resource "aws_iam_role_policy" "task_sqs" {
  count = length(var.sqs_queue_arns) > 0 ? 1 : 0

  name = "${var.name_prefix}-${var.service_name}-sqs-access"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ChangeMessageVisibility"
      ]
      Resource = var.sqs_queue_arns
    }]
  })
}

resource "aws_iam_role_policy" "task_xray" {
  count = var.enable_adot_xray ? 1 : 0

  name = "${var.name_prefix}-${var.service_name}-xray-write"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_ecs_task_definition" "service" {
  family                   = "${var.name_prefix}-${var.service_name}"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = tostring(local.task_cpu)
  memory                   = tostring(local.task_memory)
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode(concat([
    merge({
      name              = var.service_name
      image             = var.service_image
      cpu               = local.app_cpu
      memory            = local.app_memory
      memoryReservation = var.memory_reservation
      essential         = true
      links             = var.enable_adot_xray ? [local.adot_name] : []
      dependsOn = var.enable_adot_xray ? [{
        containerName = local.adot_name
        condition     = "START"
      }] : []
      portMappings = [{
        containerPort = var.container_port
        hostPort      = 0
        protocol      = "tcp"
      }]
      environment = local.environment
      secrets     = local.secrets
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.service.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }, local.repository_credentials)
  ], var.enable_adot_xray ? [local.adot_container] : []))

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-${var.service_name}"
    Layer   = "service"
    Service = var.service_name
  })
}

resource "aws_ecs_service" "service" {
  name            = "${var.name_prefix}-${var.service_name}"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.desired_count
  force_delete    = true

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  capacity_provider_strategy {
    capacity_provider = var.ecs_capacity_provider
    weight            = 1
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-${var.service_name}"
    Layer   = "service"
    Service = var.service_name
  })

  depends_on = [aws_lb_listener_rule.service]
}

resource "aws_appautoscaling_target" "service" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "service_cpu" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${var.name_prefix}-${var.service_name}-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service[0].resource_id
  scalable_dimension = aws_appautoscaling_target.service[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.service[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_target_value
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_sns_topic" "alarms" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  name = "${var.name_prefix}-${var.service_name}-alarms"

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-${var.service_name}-alarms"
    Layer   = "service"
    Service = var.service_name
  })
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.name_prefix}-${var.service_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "${var.service_name} CPU > 80%"
  alarm_actions       = [aws_sns_topic.alarms[0].arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.service.name
  }

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-${var.service_name}-cpu-high"
    Layer   = "service"
    Service = var.service_name
  })
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.name_prefix}-${var.service_name}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "${var.service_name} memory > 85%"
  alarm_actions       = [aws_sns_topic.alarms[0].arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.service.name
  }

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-${var.service_name}-memory-high"
    Layer   = "service"
    Service = var.service_name
  })
}
