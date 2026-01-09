# Project 7: Quick Start with Terraform

**Deploy entire AWS infrastructure in 15 minutes!**

---

## 🚀 Super Quick Start

```bash
# Navigate to terraform directory
cd project7/terraform-aws

# Run automated deployment script
./deploy.sh

# Follow the prompts!
```

That's it! The script will:
1. ✅ Check prerequisites (AWS CLI, Terraform)
2. ✅ Create terraform.tfvars with your IP
3. ✅ Generate SSH key pair
4. ✅ Deploy all infrastructure
5. ✅ Display connection information

---

## 📋 What Gets Deployed

### Infrastructure (Phase 1)
- **VPC**: 10.1.0.0/16 with 4 subnets (VLSM calculated)
- **Networking**: Internet Gateway, NAT Gateway, Route Tables
- **Compute**: 2 EC2 instances (webserver + cloudserver)
- **Database**: RDS MySQL 8.0
- **Storage**: S3 static website + EFS file system
- **Load Balancer**: Application Load Balancer (ready for ASG)

### High Availability (Phase 2 - after WordPress setup)
- **AMI**: Custom image from configured webserver
- **Auto Scaling**: 0-3 instances, desired: 2
- **Scaling Policy**: Scheduled scaling
- **Target Group**: Health checks configured

---

## 🎯 Step-by-Step Process

### Step 1: Deploy Infrastructure (5 minutes)

```bash
cd project7/terraform-aws
./deploy.sh
```

**What happens**:
- Creates all AWS resources
- Installs NGINX, PHP-FPM on webserver
- Downloads WordPress
- Configures S3 static website
- Mounts EFS on cloudserver

**Outputs you'll get**:
```
Webserver Public IP: x.x.x.x
RDS Endpoint: database-cheeyoung.xxxxxx.ap-southeast-1.rds.amazonaws.com
S3 Website: http://bucket-cheeyoung-xxxxx.s3-website-ap-southeast-1.amazonaws.com
Load Balancer: lb-cheeyoung-xxxxx.ap-southeast-1.elb.amazonaws.com
```

### Step 2: Configure WordPress (5 minutes)

```bash
# Get webserver IP
WEBSERVER_IP=$(terraform output -raw webserver_public_ip)

# SSH to webserver
ssh -i keypair-cheeyoung.pem ec2-user@$WEBSERVER_IP

# Configure WordPress
cd /usr/share/nginx/html/wordpress
sudo cp wp-config-sample.php wp-config.php
sudo nano wp-config.php
```

**Update these lines in wp-config.php**:
```php
define('DB_NAME', 'wordpress');
define('DB_USER', 'root');
define('DB_PASSWORD', 'YOUR_PASSWORD_FROM_TFVARS');
define('DB_HOST', 'RDS_ENDPOINT_FROM_OUTPUT');
```

**Save and exit**: Ctrl+X, Y, Enter

### Step 3: Install WordPress via Browser (3 minutes)

1. Get webserver IP: `terraform output webserver_public_ip`
2. Open browser: `http://WEBSERVER_IP/wordpress`
3. Follow WordPress 5-minute installation:
   - Site Title: "Cheeyoung WordPress Site"
   - Username: cheeyoung
   - Password: (choose strong password)
   - Email: your@email.com
   - Click "Install WordPress"

### Step 4: Deploy Auto Scaling (5 minutes)

```bash
# Run the AMI + ASG deployment script
./create-ami-and-asg.sh
```

**What happens**:
1. Stops webserver instance
2. Creates AMI (img-cheeyoung)
3. Waits for AMI to be ready
4. Updates Terraform configuration
5. Deploys Launch Template + Auto Scaling Group
6. Launches 2 instances behind Load Balancer

### Step 5: Test High Availability (2 minutes)

```bash
# Get Load Balancer URL
terraform output alb_url

# Test in browser (or from Windows 10 VM)
# http://lb-cheeyoung-xxxx.ap-southeast-1.elb.amazonaws.com/wordpress
```

**Test Auto-Healing**:
```bash
# Terminate one instance
aws ec2 terminate-instances --instance-ids i-xxxxx

# Watch Auto Scaling launch replacement
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name as-group-cheeyoung \
  --max-records 5
```

---

## 📸 Screenshot Guide

### Part 3: AWS Infrastructure (Terraform Deployed)

**VPC & Networking (8 screenshots)**:
1. AWS Console → VPC → Your VPCs (showing vpc-cheeyoung)
2. AWS Console → VPC → Subnets (showing 4 subnets with CIDRs)
3. AWS Console → VPC → Internet Gateways (igw-cheeyoung)
4. AWS Console → VPC → NAT Gateways (natg-cheeyoung)
5. AWS Console → VPC → Route Tables (public + private)
6. AWS Console → EC2 → Security Groups (secgroup-cheeyoung)
7. AWS Console → EC2 → Elastic IPs (2 allocated)
8. AWS Console → EC2 → Key Pairs (keypair-cheeyoung)

**Compute (6 screenshots)**:
9. AWS Console → EC2 → Instances (showing both running)
10. Terminal: `terraform output` (showing all outputs)
11. SSH session to webserver showing NGINX status
12. SSH session to cloudserver showing EFS mount: `ls /mnt/efs`
13. Browser: http://WEBSERVER_IP (showing NGINX or WordPress)
14. Browser: http://WEBSERVER_IP/info.php (showing PHP info)

**Database (2 screenshots)**:
15. AWS Console → RDS → Databases (database-cheeyoung running)
16. RDS database details showing endpoint

**Storage (4 screenshots)**:
17. AWS Console → S3 → Buckets (bucket-cheeyoung)
18. S3 bucket → Properties → Static Website Hosting (enabled)
19. S3 bucket showing uploaded index.html and error.html
20. Browser: S3 website URL showing your custom page

**EFS (2 screenshots)**:
21. AWS Console → EFS → File systems (efs-cheeyoung)
22. SSH to cloudserver: `df -h` showing EFS mounted at /mnt/efs

**WordPress (4 screenshots)**:
23. Browser: WordPress installation page
24. Browser: WordPress database configuration screen
25. Browser: WordPress installation success
26. Browser: WordPress dashboard (logged in)

### Part 4: High Availability (12 screenshots)

**AMI & Launch Configuration (4 screenshots)**:
27. AWS Console → EC2 → AMIs (img-cheeyoung)
28. AWS Console → EC2 → Launch Templates (as-config-cheeyoung)
29. Launch Template details showing AMI ID and configuration
30. Terminal: Output from create-ami-and-asg.sh

**Auto Scaling (4 screenshots)**:
31. AWS Console → EC2 → Auto Scaling Groups (as-group-cheeyoung)
32. Auto Scaling Group details (desired: 2, min: 0, max: 3)
33. Auto Scaling Group → Instances tab (showing 2 instances)
34. Auto Scaling Group → Activity history

**Load Balancer (4 screenshots)**:
35. AWS Console → EC2 → Load Balancers (lb-cheeyoung)
36. Load Balancer details showing DNS name
37. AWS Console → EC2 → Target Groups (cluster-cheeyoung)
38. Target Group health checks (showing healthy targets)

**Testing (4 screenshots)**:
39. Browser: Load Balancer URL showing WordPress (http://LB-DNS/wordpress)
40. Windows 10 VM → Browser → Load Balancer URL
41. Terminal: Auto Scaling activity after terminating instance
42. AWS Console showing replacement instance launched

---

## 💰 Cost Management

**Hourly Cost**: ~$0.50/hour
- EC2 t2.micro (3 instances): $0.30/hour
- RDS db.t3.micro: $0.017/hour
- NAT Gateway: $0.045/hour
- ALB: $0.0225/hour
- EFS, S3: Minimal

**Daily Cost**: ~$12/day if running 24/7

### Cleanup to Avoid Charges

```bash
# Destroy everything
cd project7/terraform-aws
terraform destroy

# Delete SSH key pair
aws ec2 delete-key-pair --key-name keypair-cheeyoung
rm keypair-cheeyoung.pem
```

---

## 🔧 Troubleshooting

### Issue: WordPress can't connect to database

**Solution**:
```bash
# SSH to webserver
ssh -i keypair-cheeyoung.pem ec2-user@WEBSERVER_IP

# Test database connection
RDS_ENDPOINT=$(terraform output -raw rds_address)
mysql -h $RDS_ENDPOINT -u root -p

# If connection fails, check security group
aws ec2 describe-security-groups --group-ids $(terraform output -raw rds_security_group_id)
```

### Issue: Load Balancer shows unhealthy targets

**Solution**:
```bash
# Check target health
aws elbv2 describe-target-health --target-group-arn TARGET_GROUP_ARN

# SSH to instance and check NGINX
ssh -i keypair-cheeyoung.pem ec2-user@INSTANCE_IP
sudo systemctl status nginx
sudo systemctl status php-fpm
```

### Issue: Can't SSH to instances

**Solution**:
```bash
# Get your current IP
curl https://checkip.amazonaws.com

# Update terraform.tfvars
my_ip = "NEW_IP/32"

# Apply changes
terraform apply
```

### Issue: S3 website not accessible

**Solution**:
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket BUCKET_NAME

# Re-apply if needed
terraform apply -target=aws_s3_bucket_policy.main
```

---

## 📚 Files Created

```
project7/terraform-aws/
├── provider.tf              # AWS provider configuration
├── variables.tf             # All input variables
├── vpc.tf                   # VPC, subnets, gateways, routes
├── security_groups.tf       # Security groups for all resources
├── ec2.tf                   # EC2 instances with user data
├── rds.tf                   # RDS MySQL database
├── s3.tf                    # S3 static website
├── efs.tf                   # EFS file system
├── alb.tf                   # Application Load Balancer
├── asg.tf                   # Auto Scaling Group (commented initially)
├── outputs.tf               # Output values
├── terraform.tfvars         # Your configuration (DO NOT commit!)
├── .gitignore              # Git ignore rules
├── deploy.sh               # Automated deployment script
├── create-ami-and-asg.sh   # AMI + ASG deployment script
└── README.md               # Detailed documentation
```

---

## ✅ Success Checklist

### Before Starting
- [ ] AWS account access verified
- [ ] AWS CLI installed and configured
- [ ] Terraform installed
- [ ] VMware Workstation ready for Parts 1 & 2

### Phase 1: Infrastructure
- [ ] Ran `./deploy.sh` successfully
- [ ] All Terraform resources created
- [ ] Can SSH to webserver
- [ ] NGINX running on webserver
- [ ] RDS database created
- [ ] S3 static website accessible
- [ ] EFS mounted on cloudserver

### Phase 2: WordPress
- [ ] wp-config.php configured
- [ ] WordPress installed via browser
- [ ] Can login to WordPress dashboard
- [ ] Test post created

### Phase 3: High Availability
- [ ] AMI created from webserver
- [ ] Launch Template created
- [ ] Auto Scaling Group deployed
- [ ] 2 instances running behind ALB
- [ ] WordPress accessible via Load Balancer DNS
- [ ] Auto-healing tested (terminate instance, verify replacement)

### Phase 4: Documentation
- [ ] All 42+ screenshots captured
- [ ] IP subnetting table included
- [ ] Architecture diagram created
- [ ] Report compiled

### Cleanup
- [ ] Terraform destroy completed
- [ ] No resources left in AWS Console
- [ ] SSH keys deleted

---

## 🎓 What You've Built

You've successfully deployed a **production-grade, highly available WordPress infrastructure** on AWS featuring:

✅ **Infrastructure as Code** - Fully automated with Terraform
✅ **High Availability** - Multi-AZ deployment, Auto Scaling
✅ **Scalability** - Auto Scaling from 0 to 3 instances
✅ **Load Balancing** - Application Load Balancer with health checks
✅ **Database** - Managed RDS MySQL in private subnet
✅ **Storage** - EFS for shared files, S3 for static content
✅ **Networking** - VPC with VLSM subnetting, public/private subnets
✅ **Security** - Security groups, private database, NAT Gateway
✅ **Monitoring** - Target health checks, Auto Scaling activities

This is **real-world enterprise architecture**! 🚀

---

## Need Help?

1. Check README.md in terraform-aws/ directory for detailed docs
2. Review terraform-aws/outputs.tf for all available outputs
3. Run `terraform show` to see current state
4. Check AWS Console for visual confirmation
5. Review CloudWatch logs for debugging

Good luck! 🎉
