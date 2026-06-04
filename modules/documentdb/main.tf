resource "aws_security_group" "documentdb" {
  name_prefix = "${var.name_prefix}-docdb-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 27017
    to_port         = 27017
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
    Name  = "${var.name_prefix}-docdb-sg"
    Layer = "service"
  })
}

resource "aws_docdb_subnet_group" "main" {
  name       = "${var.name_prefix}-docdb-subnet"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name  = "${var.name_prefix}-docdb-subnet"
    Layer = "service"
  })
}

resource "aws_docdb_cluster_parameter_group" "main" {
  family = var.parameter_group_family
  name   = "${var.name_prefix}-docdb-params"

  parameter {
    name  = "tls"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name  = "${var.name_prefix}-docdb-params"
    Layer = "service"
  })
}

resource "aws_docdb_cluster" "main" {
  cluster_identifier              = "${var.name_prefix}-docdb"
  engine                          = "docdb"
  master_username                 = var.master_username
  master_password                 = var.master_password
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  skip_final_snapshot             = var.skip_final_snapshot
  db_subnet_group_name            = aws_docdb_subnet_group.main.name
  vpc_security_group_ids          = [aws_security_group.documentdb.id]
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name
  storage_encrypted               = true

  tags = merge(var.tags, {
    Name  = "${var.name_prefix}-docdb"
    Layer = "service"
  })
}

resource "aws_docdb_cluster_instance" "main" {
  count = var.instance_count

  identifier         = "${var.name_prefix}-docdb-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = var.instance_class

  tags = merge(var.tags, {
    Name  = "${var.name_prefix}-docdb-${count.index + 1}"
    Layer = "service"
  })
}

resource "aws_secretsmanager_secret" "mongodb" {
  name = var.secret_name

  tags = merge(var.tags, {
    Name  = "${var.name_prefix}-mongodb-secret"
    Layer = "service"
  })
}

resource "aws_secretsmanager_secret_version" "mongodb" {
  secret_id = aws_secretsmanager_secret.mongodb.id

  secret_string = jsonencode(merge({
    username = var.master_username
    password = var.master_password
    endpoint = aws_docdb_cluster.main.endpoint
    uri      = "mongodb://${var.master_username}:${var.master_password}@${aws_docdb_cluster.main.endpoint}:27017/?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false&authSource=admin"
    }, {
    (var.database_secret_key) = "mongodb://${var.master_username}:${var.master_password}@${aws_docdb_cluster.main.endpoint}:27017/${var.database_name}?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false&authSource=admin"
  }))
}
