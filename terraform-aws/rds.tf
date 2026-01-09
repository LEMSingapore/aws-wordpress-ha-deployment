# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "dbsubnet-${var.iam_name}"
  subnet_ids = [aws_subnet.subnet2.id, aws_subnet.subnet3.id]

  tags = {
    Name = "dbsubnet-${var.iam_name}"
  }
}

# RDS MySQL Database
resource "aws_db_instance" "main" {
  identifier             = "database-${var.iam_name}"
  engine                 = "mysql"
  engine_version         = "8.0.39"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "wordpress"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "database-${var.iam_name}"
  }
}
