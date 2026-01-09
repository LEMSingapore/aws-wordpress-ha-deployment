output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value = {
    subnet1 = aws_subnet.subnet1.id
    subnet2 = aws_subnet.subnet2.id
    subnet3 = aws_subnet.subnet3.id
    subnet4 = aws_subnet.subnet4.id
  }
}

output "subnet_cidrs" {
  description = "Subnet CIDR blocks"
  value = {
    subnet1 = aws_subnet.subnet1.cidr_block
    subnet2 = aws_subnet.subnet2.cidr_block
    subnet3 = aws_subnet.subnet3.cidr_block
    subnet4 = aws_subnet.subnet4.cidr_block
  }
}

output "webserver_public_ip" {
  description = "Webserver public IP (Elastic IP)"
  value       = aws_eip.webserver.public_ip
}

output "webserver_instance_id" {
  description = "Webserver instance ID"
  value       = aws_instance.webserver.id
}

output "cloudserver_private_ip" {
  description = "Cloudserver private IP"
  value       = aws_instance.cloudserver.private_ip
}

output "cloudserver_instance_id" {
  description = "Cloudserver instance ID"
  value       = aws_instance.cloudserver.id
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "rds_address" {
  description = "RDS address (hostname only)"
  value       = aws_db_instance.main.address
}

output "s3_website_endpoint" {
  description = "S3 static website endpoint"
  value       = "http://${aws_s3_bucket_website_configuration.main.website_endpoint}"
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.main.id
}

output "efs_id" {
  description = "EFS file system ID"
  value       = aws_efs_file_system.main.id
}

output "efs_dns_name" {
  description = "EFS DNS name for mounting"
  value       = aws_efs_file_system.main.dns_name
}

output "nat_gateway_ip" {
  description = "NAT Gateway public IP"
  value       = aws_eip.nat.public_ip
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "Application Load Balancer URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ssh_command_webserver" {
  description = "SSH command for webserver"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_eip.webserver.public_ip}"
}

output "wordpress_config" {
  description = "WordPress database configuration details"
  value = {
    db_host     = aws_db_instance.main.address
    db_name     = "wordpress"
    db_user     = var.db_username
    db_password = "*** (check terraform.tfvars or variables) ***"
  }
  sensitive = true
}

output "ip_subnetting_table" {
  description = "IP Subnetting Table (VLSM)"
  value = <<-EOT
    IP Subnetting Table for VPC 10.1.0.0/16 (VLSM)
    =================================================
    Subnet 1 (70 hosts):
      Network:    10.1.0.0/25
      First IP:   10.1.0.1
      Last IP:    10.1.0.126
      Broadcast:  10.1.0.127

    Subnet 2 (30 hosts):
      Network:    10.1.0.128/27
      First IP:   10.1.0.129
      Last IP:    10.1.0.158
      Broadcast:  10.1.0.159

    Subnet 3 (10 hosts):
      Network:    10.1.0.160/28
      First IP:   10.1.0.161
      Last IP:    10.1.0.174
      Broadcast:  10.1.0.175

    Subnet 4 (10 hosts - Private):
      Network:    10.1.0.176/28
      First IP:   10.1.0.177
      Last IP:    10.1.0.190
      Broadcast:  10.1.0.191
  EOT
}
