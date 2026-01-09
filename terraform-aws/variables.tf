variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "iam_name" {
  description = "IAM name used for resource naming"
  type        = string
  default     = "cheeyoung"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

# Subnet CIDRs calculated using VLSM
variable "subnet_cidrs" {
  description = "CIDR blocks for subnets (VLSM)"
  type = object({
    subnet1 = string # 70 hosts - Public
    subnet2 = string # 30 hosts - Public
    subnet3 = string # 10 hosts - Public
    subnet4 = string # 10 hosts - Private
  })
  default = {
    subnet1 = "10.1.0.0/25"    # 126 usable hosts
    subnet2 = "10.1.0.128/27"  # 30 usable hosts
    subnet3 = "10.1.0.160/28"  # 14 usable hosts
    subnet4 = "10.1.0.176/28"  # 14 usable hosts (Private)
  }
}

variable "availability_zones" {
  description = "Availability zones for high availability"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "root"
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
  # You'll provide this via terraform.tfvars or command line
}

variable "my_ip" {
  description = "Your IP address for SSH access (CIDR notation)"
  type        = string
  # You'll provide this via terraform.tfvars or command line
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "keypair-cheeyoung"
}

variable "webserver_ami_id" {
  description = "AMI ID for webserver (created from configured WordPress instance)"
  type        = string
  default     = "ami-09198513b0148d8c1"
}
