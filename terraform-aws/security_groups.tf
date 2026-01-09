# Security Group for Web Servers
resource "aws_security_group" "webserver" {
  name        = "secgroup-${var.iam_name}"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  # HTTP from anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS from anywhere
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH from your IP only
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secgroup-${var.iam_name}"
  }
}

# Security Group for RDS Database
resource "aws_security_group" "rds" {
  name        = "secgroup-${var.iam_name}-rds"
  description = "Security group for RDS MySQL database"
  vpc_id      = aws_vpc.main.id

  # MySQL from webserver security group
  ingress {
    description     = "MySQL from webservers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver.id]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secgroup-${var.iam_name}-rds"
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "secgroup-${var.iam_name}-alb"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # HTTP from anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS from anywhere
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secgroup-${var.iam_name}-alb"
  }
}

# Security Group for EFS
resource "aws_security_group" "efs" {
  name        = "secgroup-${var.iam_name}-efs"
  description = "Security group for EFS"
  vpc_id      = aws_vpc.main.id

  # NFS from webserver security group
  ingress {
    description     = "NFS from instances"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver.id]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secgroup-${var.iam_name}-efs"
  }
}
