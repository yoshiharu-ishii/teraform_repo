variable "db_sg_id" {}
variable "subnet_ids" {}

variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

locals {
  engine         = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.03.2"
  family         = "aurora-mysql5.7"
}

# --------------------------------
# RDS parameter group
# --------------------------------
resource "aws_db_parameter_group" "aurora_mysql_parme" {
  name   = "${var.name}-aurora-mysql"
  family = local.family
}

# --------------------------------
# RDS parameter group
# --------------------------------
resource "aws_rds_cluster_parameter_group" "aurora_mysql_cluster_parme" {
  name   = "${var.name}-aurora-mysql"
  family = local.family

  tags = {
    Name              = "${var.name}-aurora-mysql-cluster-parame"
    Env               = var.environment
    aws-exam-resource = true
  }
}

# --------------------------------
# RDS option group
# --------------------------------
resource "aws_db_option_group" "aurora_mysql_optiongroup" {
  name                 = "${var.name}-aurora-mysql-optiongroup"
  engine_name          = "aurora-mysql"
  major_engine_version = "5.7"
}

# --------------------------------
# RDS subnet group
# --------------------------------
resource "aws_db_subnet_group" "aurora_mysql_sbunetgroup" {
  name       = "${var.name}-aurora-mysql-sbunetgroup"
  subnet_ids = split(",", var.subnet_ids)

  tags = {
    Name              = "${var.name}-aurora-mysql-sbunetgroup"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

# --------------------------------
# Aurora instance
# --------------------------------
resource "random_string" "db_password" {
  length  = 16
  special = false
}

resource "aws_rds_cluster" "aurora_mysql_cluster" {
  engine         = local.engine
  engine_version = local.engine_version

  cluster_identifier = "${var.name}-aurora-mysql-cluster"

  master_username = "admin"
  master_password = random_string.db_password.result

  # ネットーワーク系設定
  db_subnet_group_name   = aws_db_subnet_group.aurora_mysql_sbunetgroup.name
  vpc_security_group_ids = [var.db_sg_id]
  port                   = 3306

  storage_encrypted = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_mysql_cluster_parme.name

  backup_retention_period      = 7
  preferred_backup_window      = "04:00-05:00"
  preferred_maintenance_window = "Mon:05:00-Mon:08:00"

  deletion_protection = false
  skip_final_snapshot = true

  apply_immediately = true

  tags = {
    Name              = "${var.name}-aurora-mysql-cluster"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

resource "aws_rds_cluster_instance" "aurora_mysql_cluster_instance" {
  count = 2

  engine         = local.engine
  engine_version = local.engine_version

  identifier              = "${var.name}-aurora-mysql-cluster-instance-${count.index}"
  cluster_identifier      = aws_rds_cluster.aurora_mysql_cluster.id
  instance_class          = "db.t3.small"
  db_subnet_group_name    = aws_db_subnet_group.aurora_mysql_sbunetgroup.name
  db_parameter_group_name = aws_db_parameter_group.aurora_mysql_parme.name
  // TODO:モニタリング詳細 
  # monitoring_role_arn     = "${aws_iam_role.monitoring.arn}"
  # monitoring_interval = 60

  tags = {
    Name              = "${var.name}-aurora-mysql-cluster"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

output "endpoint" { value = aws_rds_cluster.aurora_mysql_cluster.endpoint }
output "username" { value = aws_rds_cluster.aurora_mysql_cluster.master_username }
output "password" { value = aws_rds_cluster.aurora_mysql_cluster.master_password }
