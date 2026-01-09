# EFS File System
resource "aws_efs_file_system" "main" {
  creation_token = "efs-${var.iam_name}"
  encrypted      = true

  tags = {
    Name = "efs-${var.iam_name}"
  }
}

# EFS Mount Target for subnet-4 (where cloudserver is)
resource "aws_efs_mount_target" "subnet4" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.subnet4.id
  security_groups = [aws_security_group.efs.id]
}

# Note: Removed subnet-1 mount target because subnet-1 and subnet-4 are in the same AZ
# EFS allows only one mount target per availability zone
