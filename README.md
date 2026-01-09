# AWS WordPress High Availability Deployment

A production-ready, highly available WordPress deployment on AWS using Infrastructure as Code (Terraform). This project demonstrates enterprise-grade cloud architecture with auto-scaling, load balancing, and multi-AZ deployment.

## Architecture Overview

This solution deploys a complete WordPress infrastructure with:

- **Multi-AZ High Availability**: WordPress instances distributed across multiple availability zones
- **Auto Scaling**: Dynamic scaling from 2 to 10 instances based on load
- **Application Load Balancer**: Distributes traffic across healthy instances
- **RDS MySQL Database**: Managed database in private subnet with automated backups
- **EFS Shared Storage**: Network file system for WordPress files shared across instances
- **S3 Static Hosting**: Optional static content delivery
- **Custom VPC**: Isolated network with public/private subnets using VLSM
- **NAT Gateway**: Secure outbound internet access for private instances

## Key Features

- **Infrastructure as Code**: Complete Terraform configuration for reproducible deployments
- **Security**: Private subnets for database, security groups, network ACLs
- **Scalability**: Auto-scaling group handles traffic spikes automatically
- **High Availability**: Multi-AZ deployment ensures resilience
- **Cost Optimized**: Uses free tier eligible resources (t2.micro, db.t3.micro)
- **Production Ready**: Includes monitoring, logging, and health checks

## Architecture Diagram

```
┌─────────────────── VPC (10.0.0.0/16) ───────────────────┐
│                                                           │
│  ┌─── Public Subnet 1 ───┐  ┌─── Public Subnet 2 ───┐  │
│  │  - ALB                 │  │  - NAT Gateway         │  │
│  │  - Internet Gateway    │  │                        │  │
│  └────────────────────────┘  └────────────────────────┘  │
│                                                           │
│  ┌── Private Subnet 1 ───┐  ┌── Private Subnet 2 ────┐  │
│  │  - WordPress EC2       │  │  - WordPress EC2       │  │
│  │  - Auto Scaling        │  │  - Auto Scaling        │  │
│  │  - EFS Mount           │  │  - EFS Mount           │  │
│  └────────────────────────┘  └────────────────────────┘  │
│                                                           │
│  ┌──────────── Database Subnet ──────────────┐          │
│  │  - RDS MySQL (Multi-AZ)                    │          │
│  └────────────────────────────────────────────┘          │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI installed and configured
- Terraform >= 1.0
- SSH key pair for EC2 access

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/LEMSingapore/aws-wordpress-ha-deployment.git
cd aws-wordpress-ha-deployment/terraform-aws
```

### 2. Configure Variables

```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your settings
vim terraform.tfvars
```

**Required variables:**
- `aws_region` - AWS region (default: us-east-1)
- `db_password` - MySQL root password (secure!)
- `key_name` - Your EC2 key pair name

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy (takes ~10-15 minutes)
terraform apply -auto-approve
```

### 4. Access WordPress

After deployment completes, Terraform outputs the ALB DNS name:

```bash
# Get ALB endpoint
terraform output alb_dns_name

# Example output:
# wordpress-alb-1234567890.us-east-1.elb.amazonaws.com
```

Access WordPress at: `http://<alb-dns-name>`

## Documentation

This repository includes comprehensive documentation:

- **[PROJECT7-START-HERE.md](PROJECT7-START-HERE.md)** - Quick overview and getting started
- **[PROJECT7-MASTER-GUIDE.md](PROJECT7-MASTER-GUIDE.md)** - Complete deployment guide with 44+ checkpoints
- **[QUICK-START-TERRAFORM.md](QUICK-START-TERRAFORM.md)** - Terraform deployment walkthrough
- **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - Common commands and troubleshooting
- **[SCREENSHOT-CHECKLIST.md](SCREENSHOT-CHECKLIST.md)** - Documentation checklist
- **[project7-architecture.md](project7-architecture.md)** - Detailed architecture explanation
- **[IP-SUBNETTING-SOLUTION.md](IP-SUBNETTING-SOLUTION.md)** - VLSM subnetting design

## Terraform Modules

The infrastructure is organized into logical Terraform files:

- `vpc.tf` - VPC, subnets, route tables, gateways
- `security_groups.tf` - Security groups and firewall rules
- `alb.tf` - Application Load Balancer configuration
- `asg.tf` - Auto Scaling Group and Launch Template
- `ec2.tf` - EC2 instance configuration
- `rds.tf` - RDS MySQL database
- `efs.tf` - Elastic File System for shared storage
- `s3.tf` - S3 bucket for static content
- `outputs.tf` - Output values for reference

## Deployment Scripts

Automated deployment scripts are included:

```bash
# Automated deployment with validation
./deploy.sh

# Create AMI and configure Auto Scaling
./create-ami-and-asg.sh
```

## Testing

### Verify Deployment

```bash
# Check all resources
terraform show

# Test WordPress accessibility
curl -I http://$(terraform output -raw alb_dns_name)

# SSH to instance (via bastion or public IP)
ssh -i ~/.ssh/your-key.pem ec2-user@<instance-ip>
```

### High Availability Testing

```bash
# Terminate an instance to test auto-scaling
aws ec2 terminate-instances --instance-ids <instance-id>

# Watch ASG create replacement instance
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names wordpress-asg
```

## Cost Estimation

**Monthly cost (approximate):**
- EC2 t2.micro instances (2-10): $8.50 - $42.50/month
- RDS db.t3.micro: $15/month
- ALB: $16/month
- EFS: ~$0.30/GB/month
- NAT Gateway: $32/month
- Data transfer: Variable

**Total: ~$72-105/month** (can be lower with AWS Free Tier)

**Free Tier Eligible:** First 12 months includes 750 hours/month of t2.micro (EC2) and db.t3.micro (RDS)

## Security Considerations

- Database in private subnet with no internet access
- Security groups restrict access to necessary ports only
- RDS automated backups enabled
- EFS encryption at rest
- SSL/TLS certificates recommended for production (not included)

**Production Recommendations:**
- Enable HTTPS with ACM certificate
- Use AWS Secrets Manager for database credentials
- Enable VPC Flow Logs
- Implement AWS WAF on ALB
- Enable CloudWatch monitoring and alarms
- Configure automated backups and disaster recovery

## Cleanup

**IMPORTANT:** To avoid ongoing charges, destroy all resources after testing:

```bash
# Destroy all infrastructure
cd terraform-aws
terraform destroy -auto-approve

# Verify cleanup
aws ec2 describe-instances --filters "Name=tag:Project,Values=wordpress-ha"
```

## Troubleshooting

### Common Issues

**WordPress not loading:**
- Check security group rules allow HTTP (80)
- Verify ALB target group health checks passing
- Check EC2 instance status and logs: `sudo tail -f /var/log/cloud-init-output.log`

**Database connection fails:**
- Verify RDS endpoint in WordPress configuration
- Check security group allows MySQL (3306) from app servers
- Test connection: `mysql -h <rds-endpoint> -u admin -p`

**Auto Scaling not working:**
- Check AMI exists and is available
- Verify launch template configuration
- Review CloudWatch logs for errors

See [QUICK-REFERENCE.md](QUICK-REFERENCE.md) for more troubleshooting tips.

## Technologies Used

- **Terraform** - Infrastructure as Code
- **AWS EC2** - Compute instances
- **AWS RDS** - Managed MySQL database
- **AWS ALB** - Application Load Balancer
- **AWS Auto Scaling** - Dynamic scaling
- **AWS EFS** - Shared file storage
- **AWS S3** - Object storage
- **AWS VPC** - Virtual Private Cloud
- **WordPress** - Content management system
- **NGINX** - Web server
- **PHP-FPM** - PHP processor

## Project Structure

```
.
├── README.md                           # This file
├── PROJECT7-MASTER-GUIDE.md            # Complete deployment guide
├── QUICK-START-TERRAFORM.md            # Terraform quick start
├── QUICK-REFERENCE.md                  # Commands reference
├── IP-SUBNETTING-SOLUTION.md          # Network design
└── terraform-aws/                      # Terraform configuration
    ├── vpc.tf                          # Network infrastructure
    ├── ec2.tf                          # EC2 instances
    ├── rds.tf                          # Database
    ├── alb.tf                          # Load balancer
    ├── asg.tf                          # Auto scaling
    ├── efs.tf                          # File system
    ├── s3.tf                           # Object storage
    ├── security_groups.tf              # Firewall rules
    ├── variables.tf                    # Input variables
    ├── outputs.tf                      # Output values
    ├── deploy.sh                       # Deployment script
    └── create-ami-and-asg.sh          # AMI creation script
```

## Contributing

This is an academic capstone project. For improvements or suggestions, please open an issue.

## License

This project is provided as-is for educational purposes.

## Author

Created as part of Cloud Computing Capstone Project 7

## Acknowledgments

- AWS documentation and best practices
- Terraform AWS provider documentation
- WordPress deployment guides

---

**Need Help?** Check the [PROJECT7-MASTER-GUIDE.md](PROJECT7-MASTER-GUIDE.md) for detailed step-by-step instructions.

**Quick Deploy?** See [QUICK-START-TERRAFORM.md](QUICK-START-TERRAFORM.md) for rapid deployment steps.
