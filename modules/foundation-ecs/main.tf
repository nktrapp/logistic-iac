data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = var.ecs_optimized_ami_ssm_parameter
}

module "sg" {
  source = "../security-group"

  name_prefix = "${var.name_prefix}-ecs-"
  vpc_id      = var.vpc_id

  ingress_rules = [
    {
      from_port                 = 32768
      to_port                   = 65535
      protocol                  = "tcp"
      source_security_group_ids = [var.alb_security_group_id]
    },
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecs-sg"
  })
}

moved {
  from = aws_security_group.ecs
  to   = module.sg.aws_security_group.this
}

resource "aws_ecs_cluster" "main" {
  name = "${var.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cluster"
  })
}

resource "aws_iam_role" "ecs_instance" {
  name = "${var.name_prefix}-ecs-instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ecs" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ssm" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${var.name_prefix}-ecs-instance"
  role = aws_iam_role.ecs_instance.name

  tags = var.tags
}

resource "aws_launch_template" "ecs" {
  name_prefix            = "${var.name_prefix}-ecs-"
  image_id               = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type          = var.ecs_instance_type
  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }

  vpc_security_group_ids = [module.sg.security_group_id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.ecs_instance_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  user_data = base64encode(<<-USERDATA
#!/bin/bash
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=${aws_ecs_cluster.main.name}
ECS_ENABLE_CONTAINER_METADATA=true
ECS_ENABLE_TASK_IAM_ROLE=true
EOF
  USERDATA
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-ecs"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-ecs"
    })
  }

  tags = var.tags
}

resource "aws_autoscaling_group" "ecs" {
  name                      = "${var.name_prefix}-ecs"
  min_size                  = var.ecs_instance_min_size
  max_size                  = var.ecs_instance_max_size
  desired_capacity          = var.ecs_instance_desired_capacity
  health_check_type         = "EC2"
  health_check_grace_period = 120
  vpc_zone_identifier       = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-ecs"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_capacity_provider" "ecs" {
  name = "${var.name_prefix}-ec2-micro"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [aws_ecs_capacity_provider.ecs.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs.name
    weight            = 1
    base              = 1
  }
}
