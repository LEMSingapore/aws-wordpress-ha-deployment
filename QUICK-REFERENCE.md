# Project 7 - Quick Reference Guide

## AWS Console Access
**Region:** ap-southeast-1 (Singapore)

---

## RESOURCE IDENTIFIERS

### VPC & Networking
| Resource | Name/ID | Details |
|----------|---------|---------|
| VPC | vpc-0b96b8770ab8f0f9a | vpc-cheeyoung (10.1.0.0/16) |
| Subnet 1 | subnet-0a6cfbbdacb918b89 | 10.1.0.0/25 (Public, 70 hosts) |
| Subnet 2 | subnet-09779b069aa3ba050 | 10.1.0.128/27 (Public, 30 hosts) |
| Subnet 3 | subnet-0b10ed05945a9377b | 10.1.0.160/28 (Public, 10 hosts) |
| Subnet 4 | subnet-0f5fb0f0f01e4a4fd | 10.1.0.176/28 (Private, 10 hosts) |
| Internet Gateway | igw-00f558f857c0e202b | igw-cheeyoung |
| NAT Gateway | nat-082d057575349ef7e | nat-cheeyoung |
| NAT Gateway EIP | 47.131.28.191 | eipalloc-025ad1d07e4cd26ce |

### EC2 Instances
| Instance | Instance ID | IP Address | Type |
|----------|-------------|------------|------|
| webserver-cheeyoung | i-084356ad796330cef | Public: 3.1.228.159<br>Private: 10.1.0.84 | Original |
| cloudserver-cheeyoung | i-0281f28f6276ac39a | Private: 10.1.0.180 | Private subnet |
| asg-instance-1 | i-035fb47747b747a0d | Dynamic | ASG |
| asg-instance-2 | i-0e90ab85e17ac76a7 | Dynamic | ASG |

### Security Groups
| Security Group | ID | Purpose |
|----------------|-----|---------|
| sg-webserver | sg-097c903e047436c36 | Web servers (80, 443, 22) |
| sg-rds | sg-01e5fc22029bcd4da | RDS MySQL (3306) |
| sg-alb | sg-02433ba572831d420 | Load Balancer (80) |
| sg-efs | sg-0d3850b00c67a9023 | EFS NFS (2049) |

### Database
| Resource | Value |
|----------|-------|
| DB Instance | database-cheeyoung |
| DB Identifier | db-MY5FBVJJMV7ZNU2TVEHS2WWW7E |
| Endpoint | database-cheeyoung.cfaggeyem07s.ap-southeast-1.rds.amazonaws.com |
| Port | 3306 |
| Engine | MySQL 8.0.39 |
| Database Name | wordpress |
| Username | root |
| Password | k9icn5SOJ2oee10f |

### Storage
| Resource | ID/Name | Details |
|----------|---------|---------|
| S3 Bucket | bucket-cheeyoung-0itb3dj0 | Static website |
| EFS | fs-0a7f0139a3fd82d90 | efs-cheeyoung |
| EFS Mount Target | fsmt-01ba3f4fa8e414a65 | subnet-4 |

### Load Balancer & Auto Scaling
| Resource | ID/Name | Details |
|----------|---------|---------|
| ALB | lb-cheeyoung | arn:...loadbalancer/app/lb-cheeyoung/b69f7c491a6893b1 |
| Target Group | cluster-cheeyoung | arn:...targetgroup/cluster-cheeyoung/c7c94fd0ed8e275a |
| Launch Template | as-config-cheeyoung | lt-027bed3386b472467 |
| ASG | as-group-cheeyoung | Min: 0, Desired: 2, Max: 3 |
| AMI | ami-09198513b0148d8c1 | wordpress-webserver-cheeyoung-20260108-013840 |

---

## ACCESS URLS

### WordPress
- **Direct URL:** http://3.1.228.159
- **Admin Panel:** http://3.1.228.159/wp-admin
- **Via Load Balancer:** http://lb-cheeyoung-673651012.ap-southeast-1.elb.amazonaws.com

### S3 Static Website
- **Website URL:** http://bucket-cheeyoung-0itb3dj0.s3-website-ap-southeast-1.amazonaws.com

### AWS Console Links
- **VPC:** https://ap-southeast-1.console.aws.amazon.com/vpc/home?region=ap-southeast-1
- **EC2:** https://ap-southeast-1.console.aws.amazon.com/ec2/home?region=ap-southeast-1
- **RDS:** https://ap-southeast-1.console.aws.amazon.com/rds/home?region=ap-southeast-1
- **S3:** https://s3.console.aws.amazon.com/s3/buckets
- **EFS:** https://ap-southeast-1.console.aws.amazon.com/efs/home?region=ap-southeast-1
- **Load Balancers:** https://ap-southeast-1.console.aws.amazon.com/ec2/home?region=ap-southeast-1#LoadBalancers:
- **Auto Scaling:** https://ap-southeast-1.console.aws.amazon.com/ec2/home?region=ap-southeast-1#AutoScalingGroups:

---

## SSH COMMANDS

### Connect to Webserver
```bash
cd /Users/cheeyoungchang/Projects/cloud-capstone/project7/terraform-aws
ssh -i keypair-cheeyoung.pem ec2-user@3.1.228.159
```

### Connect to Cloudserver (via webserver as jump host)
```bash
# First SSH to webserver
ssh -i keypair-cheeyoung.pem ec2-user@3.1.228.159

# Then from webserver, SSH to cloudserver
ssh ec2-user@10.1.0.180
```

### Check EFS Mount on Cloudserver
```bash
ssh -i keypair-cheeyoung.pem ec2-user@3.1.228.159
ssh ec2-user@10.1.0.180
df -h | grep efs
ls -la /mnt/efs
cat /mnt/efs/test.txt
```

---

## DATABASE COMMANDS

### Connect to RDS from Webserver
```bash
ssh -i keypair-cheeyoung.pem ec2-user@3.1.228.159
mysql -h database-cheeyoung.cfaggeyem07s.ap-southeast-1.rds.amazonaws.com -u root -p
# Password: k9icn5SOJ2oee10f
```

### MySQL Commands
```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_posts LIMIT 5;
SELECT * FROM wp_users;
```

---

## TERRAFORM COMMANDS

### View Outputs
```bash
cd /Users/cheeyoungchang/Projects/cloud-capstone/project7/terraform-aws
terraform output
terraform output ip_subnetting_table
terraform output wordpress_config
```

### Check Resources
```bash
terraform state list
terraform show
```

---

## AWS CLI COMMANDS

### Check Auto Scaling Group
```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names as-group-cheeyoung \
  --region ap-southeast-1
```

### Check Load Balancer Target Health
```bash
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:ap-southeast-1:588738601599:targetgroup/cluster-cheeyoung/c7c94fd0ed8e275a \
  --region ap-southeast-1
```

### List EC2 Instances
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=Project7-HA-WordPress" \
  --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],State.Name,PublicIpAddress,PrivateIpAddress]' \
  --output table \
  --region ap-southeast-1
```

### Check AMI
```bash
aws ec2 describe-images \
  --image-ids ami-09198513b0148d8c1 \
  --region ap-southeast-1
```

---

## TESTING HIGH AVAILABILITY

### Test 1: Terminate an ASG Instance
```bash
# Get current instances
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names as-group-cheeyoung \
  --query 'AutoScalingGroups[0].Instances[*].InstanceId' \
  --region ap-southeast-1

# Terminate one instance (it will auto-heal)
aws ec2 terminate-instances \
  --instance-ids i-035fb47747b747a0d \
  --region ap-southeast-1

# Watch auto-healing
watch -n 5 'aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names as-group-cheeyoung \
  --query "AutoScalingGroups[0].Instances" \
  --region ap-southeast-1'
```

### Test 2: Manual Scaling
```bash
# Scale up to 3 instances
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name as-group-cheeyoung \
  --desired-capacity 3 \
  --region ap-southeast-1

# Scale down to 1 instance
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name as-group-cheeyoung \
  --desired-capacity 1 \
  --region ap-southeast-1
```

### Test 3: Load Test (Optional)
```bash
# Simple load test
for i in {1..50}; do
  curl -s http://lb-cheeyoung-673651012.ap-southeast-1.elb.amazonaws.com/ | head -1
  echo "Request $i completed"
  sleep 1
done
```

---

## USEFUL FILE LOCATIONS

### WordPress Files on Webserver
```bash
# WordPress root
/usr/share/nginx/html/wordpress/

# Configuration
/usr/share/nginx/html/wordpress/wp-config.php

# NGINX config
/etc/nginx/conf.d/wordpress.conf

# PHP-FPM config
/etc/php-fpm.d/www.conf

# Logs
/var/log/nginx/access.log
/var/log/nginx/error.log
/var/log/php-fpm/www-error.log
```

---

## TROUBLESHOOTING

### WordPress Not Loading
```bash
ssh -i keypair-cheeyoung.pem ec2-user@3.1.228.159
sudo systemctl status nginx
sudo systemctl status php-fpm
sudo tail -f /var/log/nginx/error.log
```

### Database Connection Issues
```bash
# Test from webserver
mysql -h database-cheeyoung.cfaggeyem07s.ap-southeast-1.rds.amazonaws.com -u root -p

# Check WordPress config
cat /usr/share/nginx/html/wordpress/wp-config.php | grep DB_
```

### EFS Not Mounted
```bash
ssh ec2-user@10.1.0.180
sudo mount -a
df -h | grep efs
```

---

## PROJECT STRUCTURE

```
project7/
├── terraform-aws/              # Terraform configuration
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── vpc.tf
│   ├── ec2.tf
│   ├── rds.tf
│   ├── s3.tf
│   ├── efs.tf
│   ├── alb.tf
│   ├── asg.tf
│   ├── security_groups.tf
│   ├── outputs.tf
│   └── keypair-cheeyoung.pem  # SSH key
├── SCREENSHOT-CHECKLIST.md     # This guide
├── QUICK-REFERENCE.md          # Quick reference
├── IP-SUBNETTING-SOLUTION.md   # VLSM calculations
└── screenshots/                # Your screenshots folder
    ├── part3-aws-config/
    └── part4-high-availability/
```

---

## IMPORTANT NOTES

1. **Keep credentials secure**: Don't share passwords in screenshots
2. **All resources in ap-southeast-1**: Singapore region
3. **SSH key location**: `/Users/cheeyoungchang/Projects/cloud-capstone/project7/terraform-aws/keypair-cheeyoung.pem`
4. **IAM user**: project7-terraform (Account: 588738601599)
5. **Cost awareness**: Remember to clean up resources when done

---

## CLEANUP (When Project is Complete)

```bash
cd /Users/cheeyoungchang/Projects/cloud-capstone/project7/terraform-aws

# Destroy all resources
terraform destroy -auto-approve

# Manually delete AMI if needed
aws ec2 deregister-image --image-id ami-09198513b0148d8c1 --region ap-southeast-1
```

**Last Updated:** 2026-01-08
