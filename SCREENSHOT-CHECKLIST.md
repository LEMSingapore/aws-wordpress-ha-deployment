# Project 7 - Screenshot Checklist

## Overview
This document lists all screenshots required for Project 7 documentation, organized by project parts.

---

## PART 3: AWS Cloud Configuration (Main Focus)

### Task 3.1: VPC Configuration
**AWS Console → VPC Dashboard**

- [ ] **Screenshot 1**: VPC list showing `vpc-cheeyoung` (vpc-0b96b8770ab8f0f9a)
  - Location: VPC → Your VPCs
  - Show: VPC ID, Name, CIDR block (10.1.0.0/16)

- [ ] **Screenshot 2**: VPC details page
  - Show: DNS settings, DHCP options, route tables

### Task 3.2: Subnets Configuration
**AWS Console → VPC → Subnets**

- [ ] **Screenshot 3**: Subnets list showing all 4 subnets
  - subnet-1: 10.1.0.0/25 (Public)
  - subnet-2: 10.1.0.128/27 (Public)
  - subnet-3: 10.1.0.160/28 (Public)
  - subnet-4: 10.1.0.176/28 (Private)
  - Show: Subnet IDs, Names, CIDR blocks, AZs

- [ ] **Screenshot 4**: IP Subnetting Table (from Terraform output)
  ```
  terraform output ip_subnetting_table
  ```

### Task 3.3: Internet Gateway
**AWS Console → VPC → Internet Gateways**

- [ ] **Screenshot 5**: Internet Gateway list
  - Show: igw-cheeyoung (igw-00f558f857c0e202b)
  - State: Attached to VPC

- [ ] **Screenshot 6**: Internet Gateway details
  - Show: VPC attachment

### Task 3.4: Route Tables
**AWS Console → VPC → Route Tables**

- [ ] **Screenshot 7**: Public Route Table
  - Name: rtb-public-cheeyoung
  - Show: Routes including 0.0.0.0/0 → IGW

- [ ] **Screenshot 8**: Private Route Table
  - Name: rtb-private-cheeyoung
  - Show: Routes including 0.0.0.0/0 → NAT Gateway

- [ ] **Screenshot 9**: Subnet Associations
  - Show: Which subnets are associated with which route tables

### Task 3.5: Security Groups
**AWS Console → EC2 → Security Groups**

- [ ] **Screenshot 10**: Security Groups list
  - sg-webserver
  - sg-rds
  - sg-alb
  - sg-efs

- [ ] **Screenshot 11**: Webserver Security Group inbound rules
  - Port 22 (SSH) from your IP
  - Port 80 (HTTP) from anywhere
  - Port 443 (HTTPS) from anywhere

- [ ] **Screenshot 12**: RDS Security Group inbound rules
  - Port 3306 (MySQL) from webserver security group

- [ ] **Screenshot 13**: ALB Security Group inbound rules
  - Port 80 from anywhere

- [ ] **Screenshot 14**: EFS Security Group inbound rules
  - Port 2049 (NFS) from webserver security group

### Task 3.6: EC2 Instances
**AWS Console → EC2 → Instances**

- [ ] **Screenshot 15**: EC2 Instances list
  - Show: webserver-cheeyoung (i-084356ad796330cef)
  - Show: cloudserver-cheeyoung (i-0281f28f6276ac39a)
  - Show: ASG instances (i-035fb47747b747a0d, i-0e90ab85e17ac76a7)

- [ ] **Screenshot 16**: webserver instance details
  - Show: Public IP (3.1.228.159), Private IP, VPC, Subnet, Security Groups

- [ ] **Screenshot 17**: cloudserver instance details
  - Show: Private IP (10.1.0.180), VPC, Subnet (private)

- [ ] **Screenshot 18**: SSH connection to webserver
  ```bash
  ssh -i keypair-cheeyoung.pem ec2-user@3.1.228.159
  # Run: hostname, ifconfig, df -h
  ```

### Task 3.7: NAT Gateway
**AWS Console → VPC → NAT Gateways**

- [ ] **Screenshot 19**: NAT Gateway list
  - Show: nat-cheeyoung (nat-082d057575349ef7e)
  - Show: Elastic IP (47.131.28.191)
  - Show: Subnet, State

- [ ] **Screenshot 20**: NAT Gateway details
  - Show: Associated subnet, Elastic IP allocation

### Task 3.8: Elastic IP
**AWS Console → EC2 → Elastic IPs**

- [ ] **Screenshot 21**: Elastic IPs list
  - EIP for NAT Gateway: 47.131.28.191
  - EIP for webserver: 3.1.228.159 (associated with i-084356ad796330cef)

### Task 3.9: RDS Database
**AWS Console → RDS → Databases**

- [ ] **Screenshot 22**: RDS instance list
  - Show: database-cheeyoung

- [ ] **Screenshot 23**: RDS instance details
  - Show: Endpoint, Port, Engine (MySQL 8.0.39), Storage, VPC

- [ ] **Screenshot 24**: RDS DB Subnet Group
  - Show: dbsubnet-cheeyoung
  - Show: Subnets included (subnet-2, subnet-3)

- [ ] **Screenshot 25**: Test database connection from webserver
  ```bash
  ssh -i keypair-cheeyoung.pem ec2-user@3.1.228.159
  mysql -h database-cheeyoung.cfaggeyem07s.ap-southeast-1.rds.amazonaws.com -u root -p
  # Password: k9icn5SOJ2oee10f
  # Run: SHOW DATABASES; USE wordpress; SHOW TABLES;
  ```

### Task 3.10: WordPress Installation
**Browser Access**

- [ ] **Screenshot 26**: WordPress login page
  - URL: http://3.1.228.159/wp-admin

- [ ] **Screenshot 27**: WordPress dashboard
  - Show: Site title "Capstone Project 7 News"

- [ ] **Screenshot 28**: WordPress site homepage
  - URL: http://3.1.228.159

- [ ] **Screenshot 29**: WordPress posts or pages
  - Show some content

- [ ] **Screenshot 30**: WordPress database configuration
  - File: wp-config.php showing database settings
  ```bash
  ssh -i keypair-cheeyoung.pem ec2-user@3.1.228.159
  sudo cat /usr/share/nginx/html/wordpress/wp-config.php | grep DB_
  ```

### Task 3.11: S3 Static Website
**AWS Console → S3**

- [ ] **Screenshot 31**: S3 buckets list
  - Show: bucket-cheeyoung-0itb3dj0

- [ ] **Screenshot 32**: S3 bucket properties
  - Show: Static website hosting enabled
  - Show: Bucket website endpoint

- [ ] **Screenshot 33**: S3 bucket contents
  - Show: index.html, error.html files

- [ ] **Screenshot 34**: S3 website in browser
  - URL: http://bucket-cheeyoung-0itb3dj0.s3-website-ap-southeast-1.amazonaws.com

- [ ] **Screenshot 35**: S3 bucket policy
  - Show: Public read access policy

### Task 3.12: EFS File System
**AWS Console → EFS**

- [ ] **Screenshot 36**: EFS file systems list
  - Show: efs-cheeyoung (fs-0a7f0139a3fd82d90)

- [ ] **Screenshot 37**: EFS file system details
  - Show: Mount targets, Availability zones, Performance mode

- [ ] **Screenshot 38**: EFS mount targets
  - Show: Mount target in subnet-4

- [ ] **Screenshot 39**: Test EFS mount on cloudserver
  ```bash
  # Connect to cloudserver via webserver (jump host)
  ssh -i keypair-cheeyoung.pem ec2-user@3.1.228.159
  ssh ec2-user@10.1.0.180
  # Run: df -h | grep efs
  # Run: ls -la /mnt/efs
  ```

---

## PART 4: High Availability Configuration

### Task 4.1: AMI Creation
**AWS Console → EC2 → AMIs**

- [ ] **Screenshot 40**: AMIs list
  - Show: wordpress-webserver-cheeyoung-20260108-013840 (ami-09198513b0148d8c1)

- [ ] **Screenshot 41**: AMI details
  - Show: Name, AMI ID, Creation date, Size, Description

### Task 4.2: Launch Template
**AWS Console → EC2 → Launch Templates**

- [ ] **Screenshot 42**: Launch Templates list
  - Show: as-config-cheeyoung

- [ ] **Screenshot 43**: Launch Template details
  - Show: AMI ID, Instance type, Security groups, User data

### Task 4.3: Auto Scaling Group
**AWS Console → EC2 → Auto Scaling Groups**

- [ ] **Screenshot 44**: Auto Scaling Groups list
  - Show: as-group-cheeyoung

- [ ] **Screenshot 45**: Auto Scaling Group details
  - Show: Desired capacity: 2, Min: 0, Max: 3
  - Show: Current instances: 2

- [ ] **Screenshot 46**: ASG Instances tab
  - Show: 2 running instances (InService, Healthy)

- [ ] **Screenshot 47**: ASG Activity tab
  - Show: Launch activities

- [ ] **Screenshot 48**: ASG Scheduled Actions
  - Show: scale-up-cheeyoung (every minute)

### Task 4.4: Application Load Balancer
**AWS Console → EC2 → Load Balancers**

- [ ] **Screenshot 49**: Load Balancers list
  - Show: lb-cheeyoung

- [ ] **Screenshot 50**: ALB details
  - Show: DNS name, State, Scheme (internet-facing)

- [ ] **Screenshot 51**: ALB Listeners
  - Show: HTTP:80 listener forwarding to target group

- [ ] **Screenshot 52**: Target Group details
  - Show: cluster-cheeyoung
  - Show: Health check settings

- [ ] **Screenshot 53**: Target Group targets
  - Show: 2 targets (both healthy)
  - Show: Instance IDs and health status

- [ ] **Screenshot 54**: WordPress via Load Balancer
  - URL: http://lb-cheeyoung-673651012.ap-southeast-1.elb.amazonaws.com
  - Show: WordPress site loading

### Task 4.5: High Availability Testing

- [ ] **Screenshot 55**: Before terminating instance
  - Show: ASG with 2 instances

- [ ] **Screenshot 56**: Terminate one ASG instance
  - AWS Console: Select instance → Actions → Instance State → Terminate

- [ ] **Screenshot 57**: Auto-healing in progress
  - Show: ASG launching new instance

- [ ] **Screenshot 58**: After auto-healing
  - Show: ASG back to 2 instances (new instance ID)

- [ ] **Screenshot 59**: Load Balancer still serving traffic
  - Refresh browser showing WordPress still accessible during failover

- [ ] **Screenshot 60**: ASG Activity history
  - Show: Termination and launch events

---

## ADDITIONAL SCREENSHOTS

### Network Diagram
- [ ] **Screenshot 61**: Draw or capture your architecture diagram showing:
  - VPC with 4 subnets
  - Internet Gateway
  - NAT Gateway
  - EC2 instances
  - RDS database
  - EFS file system
  - ALB
  - Auto Scaling Group

### Terraform Output
- [ ] **Screenshot 62**: Terraform outputs
  ```bash
  terraform output
  ```

### Resource Tags
- [ ] **Screenshot 63**: Show resources with consistent tags
  - Project, Environment, ManagedBy, Student

### Cost Explorer (Optional)
- [ ] **Screenshot 64**: AWS Cost Explorer showing project costs

---

## QUICK ACCESS URLS

**Webserver Direct Access:**
- SSH: `ssh -i keypair-cheeyoung.pem ec2-user@3.1.228.159`
- WordPress: http://3.1.228.159
- WordPress Admin: http://3.1.228.159/wp-admin

**Load Balancer Access:**
- ALB URL: http://lb-cheeyoung-673651012.ap-southeast-1.elb.amazonaws.com

**S3 Website:**
- S3 URL: http://bucket-cheeyoung-0itb3dj0.s3-website-ap-southeast-1.amazonaws.com

**Database:**
- Endpoint: database-cheeyoung.cfaggeyem07s.ap-southeast-1.rds.amazonaws.com
- Username: root
- Password: k9icn5SOJ2oee10f
- Database: wordpress

---

## SCREENSHOT TIPS

1. **Clear naming**: Name files like `01-vpc-list.png`, `02-vpc-details.png`, etc.
2. **Full screen**: Capture full browser window showing AWS console
3. **Highlight important info**: Use arrows or boxes to highlight key information
4. **Consistent quality**: Use PNG format for clarity
5. **Organize folders**:
   - `screenshots/part3-aws-config/`
   - `screenshots/part4-high-availability/`
6. **Include metadata**: Date/time stamps visible in screenshots

---

## VERIFICATION CHECKLIST

Before submitting, verify you have:
- [ ] All VPC components (VPC, subnets, IGW, NAT, route tables)
- [ ] All security groups with rules visible
- [ ] EC2 instances (standalone + ASG instances)
- [ ] RDS database with connection test
- [ ] WordPress fully configured and accessible
- [ ] S3 static website working
- [ ] EFS mounted and accessible
- [ ] AMI created from webserver
- [ ] Launch template configured
- [ ] Auto Scaling Group with 2+ instances
- [ ] Load Balancer with healthy targets
- [ ] HA testing (terminate and auto-heal)
- [ ] Architecture diagram

**Total Screenshots Required:** 64+

Good luck with your documentation!
