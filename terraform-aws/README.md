# Project 7: AWS High Availability WordPress - Terraform Deployment

**Student**: Chee Young Chang
**IAM Name**: cheeyoung
**Region**: ap-southeast-1 (Singapore)
**VPC CIDR**: 10.1.0.0/16

---

## Quick Start

### Prerequisites

1. AWS Account with IAM credentials configured
2. Terraform installed (v1.0+)
3. AWS CLI installed and configured
4. SSH key pair generated

### Step 1: Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: ap-southeast-1
# Default output format: json
```

### Step 2: Generate SSH Key Pair

```bash
# Create SSH key pair in AWS
aws ec2 create-key-pair \
  --key-name keypair-cheeyoung \
  --query 'KeyMaterial' \
  --output text > keypair-cheeyoung.pem

chmod 400 keypair-cheeyoung.pem
```

### Step 3: Configure Variables

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
nano terraform.tfvars
```

Required variables in `terraform.tfvars`:
```hcl
my_ip       = "YOUR_PUBLIC_IP/32"   # Get from https://whatismyipaddress.com
db_password = "YourStrongPassword123!"
```

### Step 4: Deploy Phase 1 (Infrastructure + Webserver)

```bash
# Initialize Terraform
terraform init

# Preview what will be created
terraform plan

# Deploy infrastructure
terraform apply

# Save outputs
terraform output > deployment-info.txt
```

This creates:
- VPC with 4 subnets (VLSM)
- Internet Gateway
- NAT Gateway
- Security Groups
- 2 EC2 instances (cloudserver + webserver)
- RDS MySQL database
- S3 static website
- EFS file system
- Application Load Balancer (ready for ASG)

### Step 5: Configure WordPress

```bash
# Get webserver IP
WEBSERVER_IP=$(terraform output -raw webserver_public_ip)

# Get RDS endpoint
RDS_ENDPOINT=$(terraform output -raw rds_address)

# SSH into webserver
ssh -i keypair-cheeyoung.pem ec2-user@$WEBSERVER_IP

# On webserver, configure WordPress
cd /usr/share/nginx/html/wordpress
sudo cp wp-config-sample.php wp-config.php
sudo nano wp-config.php

# Update these lines:
# define('DB_NAME', 'wordpress');
# define('DB_USER', 'root');
# define('DB_PASSWORD', 'YourStrongPassword123!');
# define('DB_HOST', '<RDS_ENDPOINT>');

# Exit SSH
exit
```

### Step 6: Install WordPress via Browser

```bash
# Get webserver IP
terraform output webserver_public_ip

# Open in browser:
# http://<WEBSERVER_IP>/wordpress

# Follow WordPress installation wizard:
# 1. Select language
# 2. Enter site title: "Cheeyoung WordPress Site"
# 3. Enter username: cheeyoung
# 4. Enter password (your choice)
# 5. Enter email
# 6. Click "Install WordPress"
```

### Step 7: Create AMI from Webserver

```bash
# Get webserver instance ID
INSTANCE_ID=$(terraform output -raw webserver_instance_id)

# Stop instance
aws ec2 stop-instances --instance-ids $INSTANCE_ID

# Wait for instance to stop
aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID

# Create AMI
AMI_ID=$(aws ec2 create-image \
  --instance-id $INSTANCE_ID \
  --name "img-cheeyoung" \
  --description "WordPress webserver image for Auto Scaling" \
  --query 'ImageId' \
  --output text)

echo "AMI ID: $AMI_ID"

# Wait for AMI to be available (takes 5-10 minutes)
aws ec2 wait image-available --image-ids $AMI_ID

echo "AMI is ready!"
```

### Step 8: Deploy Phase 2 (Auto Scaling + High Availability)

```bash
# Add AMI ID to terraform.tfvars
echo "webserver_ami_id = \"$AMI_ID\"" >> terraform.tfvars

# Uncomment Auto Scaling configuration in asg.tf
# Edit asg.tf and remove the /* and */ comment blocks

# Apply changes
terraform apply

# Verify Auto Scaling Group
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names as-group-cheeyoung

# Get Load Balancer URL
terraform output alb_url
```

### Step 9: Test High Availability

```bash
# Get Load Balancer URL
ALB_URL=$(terraform output -raw alb_dns_name)

# Test from command line
curl -I http://$ALB_URL/wordpress

# Open in browser (from Windows 10 VM)
# http://<ALB_DNS_NAME>/wordpress

# Verify instances in target group
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)

# Terminate one instance to test auto-healing
# Auto Scaling will automatically launch a replacement
```

---

## Infrastructure Details

### VPC and Networking

- **VPC**: 10.1.0.0/16
- **Subnets** (VLSM):
  - subnet-1: 10.1.0.0/25 (Public, 126 hosts) - Webservers
  - subnet-2: 10.1.0.128/27 (Public, 30 hosts) - Multi-AZ
  - subnet-3: 10.1.0.160/28 (Public, 14 hosts) - Multi-AZ
  - subnet-4: 10.1.0.176/28 (Private, 14 hosts) - Cloudserver

### Security Groups

- **webserver**: HTTP (80), HTTPS (443), SSH (22 from your IP)
- **rds**: MySQL (3306 from webserver SG)
- **alb**: HTTP (80), HTTPS (443) from anywhere
- **efs**: NFS (2049 from webserver SG)

### Resources Created

| Resource | Name | Details |
|----------|------|---------|
| VPC | vpc-cheeyoung | 10.1.0.0/16 |
| EC2 | webserver-cheeyoung | Amazon Linux 2, NGINX, PHP, WordPress |
| EC2 | cloudserver-cheeyoung | Amazon Linux 2, EFS mounted |
| RDS | database-cheeyoung | MySQL 8.0.28, db.t3.micro |
| S3 | bucket-cheeyoung-* | Static website enabled |
| EFS | efs-cheeyoung | Encrypted |
| ALB | lb-cheeyoung | Internet-facing |
| ASG | as-group-cheeyoung | Min: 0, Max: 3, Desired: 2 |

---

## Useful Commands

### View Resources

```bash
# Show all outputs
terraform output

# Show specific output
terraform output webserver_public_ip
terraform output alb_dns_name

# Show state
terraform show

# List resources
terraform state list
```

### SSH Access

```bash
# SSH to webserver
ssh -i keypair-cheeyoung.pem ec2-user@$(terraform output -raw webserver_public_ip)

# SSH to cloudserver (via webserver as jump host)
ssh -i keypair-cheeyoung.pem \
  -o ProxyCommand="ssh -i keypair-cheeyoung.pem -W %h:%p ec2-user@$(terraform output -raw webserver_public_ip)" \
  ec2-user@$(terraform output -raw cloudserver_private_ip)
```

### Database Access

```bash
# Connect to RDS from webserver
ssh -i keypair-cheeyoung.pem ec2-user@$(terraform output -raw webserver_public_ip)

mysql -h $(terraform output -raw rds_address) -u root -p
# Enter password from terraform.tfvars
```

### Monitor Auto Scaling

```bash
# View Auto Scaling activity
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name as-group-cheeyoung \
  --max-records 10

# View current instances
aws autoscaling describe-auto-scaling-instances
```

### Cleanup

```bash
# Destroy all resources
terraform destroy

# Delete key pair
aws ec2 delete-key-pair --key-name keypair-cheeyoung
rm keypair-cheeyoung.pem
```

---

## Troubleshooting

### WordPress Can't Connect to Database

```bash
# Check security group allows MySQL
aws ec2 describe-security-groups --group-ids <RDS_SG_ID>

# Test connection from webserver
ssh -i keypair-cheeyoung.pem ec2-user@$(terraform output -raw webserver_public_ip)
mysql -h <RDS_ENDPOINT> -u root -p
```

### Load Balancer Shows Unhealthy Targets

```bash
# Check target health
aws elbv2 describe-target-health --target-group-arn <TG_ARN>

# Check instance is running
aws ec2 describe-instances --instance-ids <INSTANCE_ID>

# Check NGINX is running on instance
ssh -i keypair-cheeyoung.pem ec2-user@<INSTANCE_IP>
sudo systemctl status nginx
```

### Can't SSH to Instances

```bash
# Verify your IP in terraform.tfvars
curl https://checkip.amazonaws.com

# Update terraform.tfvars with new IP
my_ip = "NEW_IP/32"

# Apply changes
terraform apply
```

---

## Screenshot Checklist

### Part 3: AWS Resources (Terraform)
- [ ] VPC created (AWS Console)
- [ ] 4 subnets created with correct CIDRs
- [ ] Internet Gateway attached
- [ ] NAT Gateway running
- [ ] Route tables configured
- [ ] Security groups with rules
- [ ] EC2 instances running
- [ ] RDS database available
- [ ] S3 bucket with website enabled
- [ ] S3 static website accessible in browser
- [ ] EFS file system created
- [ ] EFS mounted on cloudserver (ls /mnt/efs)
- [ ] WordPress installation page
- [ ] WordPress installed and accessible

### Part 4: High Availability (Terraform)
- [ ] AMI created from webserver
- [ ] Launch Template created
- [ ] Target Group created
- [ ] Application Load Balancer created
- [ ] Auto Scaling Group created
- [ ] Auto Scaling Group showing 2 instances
- [ ] Scheduled scaling policy
- [ ] Load Balancer URL accessible
- [ ] WordPress accessible via Load Balancer
- [ ] Test from Windows 10 VM

---

## Cost Estimate

**Hourly**: ~$0.50/hour
**Daily**: ~$12/day
**Monthly** (if left running): ~$360/month

**Breakdown**:
- EC2 t2.micro x2-3: $0.20/hour
- RDS db.t3.micro: $0.017/hour
- NAT Gateway: $0.045/hour
- ALB: $0.0225/hour
- EFS: $0.30/GB-month (minimal usage)
- S3: $0.023/GB-month (minimal usage)

**Recommendation**: Destroy resources after testing to avoid charges.

---

## Next Steps After Terraform Deployment

1. ✅ Complete Part 1: Install Windows 10 Pro VM
2. ✅ Complete Part 2: Install CentOS 7.6 VM
3. ✅ Test WordPress via Load Balancer from Windows VM
4. ✅ Capture all 44+ screenshots
5. ✅ Fill out IP subnetting table
6. ✅ Create architecture diagram
7. ✅ Compile final report
8. ✅ Clean up: `terraform destroy`

Good luck! 🚀
