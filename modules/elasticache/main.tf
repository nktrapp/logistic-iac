resource "aws_security_group" "redis" {
  name_prefix = "${var.name_prefix}-redis-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name  = "${var.name_prefix}-redis-sg"
    Layer = "service"
  })
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name_prefix}-redis-subnet"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name  = "${var.name_prefix}-redis-subnet"
    Layer = "service"
  })
}

resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.name_prefix}-redis"
  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_nodes      = 1
  parameter_group_name = var.parameter_group_name
  port                 = var.port
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.redis.id]

  tags = merge(var.tags, {
    Name  = "${var.name_prefix}-redis"
    Layer = "service"
  })
}

resource "aws_secretsmanager_secret" "redis" {
  name = var.secret_name

  tags = merge(var.tags, {
    Name  = "${var.name_prefix}-redis-secret"
    Layer = "service"
  })
}

resource "aws_secretsmanager_secret_version" "redis" {
  secret_id = aws_secretsmanager_secret.redis.id

  secret_string = jsonencode({
    endpoint = aws_elasticache_cluster.main.cache_nodes[0].address
    port     = var.port
  })
}
