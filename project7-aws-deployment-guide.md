# Project 7 - AWS WordPress Deployment Guide
## Complete Step-by-Step Instructions

**Student:** [Your Name]  
**Date:** January 3, 2026  
**Project:** AWS WordPress with High Availability

---

## Table of Contents

### Part 3: AWS Resources Configuration
1. AWS IAM Sign-in
2. Region Configuration
3. Network Configuration (VPC, Subnets, IGW, Route Tables, Security Groups)
4. IP Subnetting
5. EC2 Configuration (Cloud Server + Web Server)
6. Web Server Configuration (NGINX, PHP-FPM, WordPress)
7. RDS Configuration (MySQL Database)
8. WordPress Installation
9. S3 Static Website Hosting
10. NAT Gateway Configuration
11. EFS Configuration
12. VPC Peering

### Part 4: High Availability
1. AMI Image Creation
2. Auto Scaling & Load Balancer Configuration
3. Scaling Policy
4. Connectivity Verification

---

# PART 3: AWS RESOURCES CONFIGURATION

## Task 1: AWS IAM Sign-in

### Steps:
1. Navigate to AWS Console: https://console.aws.amazon.com/
2. Sign in with your IAM credentials:
   - Account ID: [Provided by instructor]
   - IAM username: [Your IAM username]
   - Password: [Your password]

### Screenshot Required:
📸 **Screenshot 1:** AWS Management Console homepage after successful login

---

## Task 2: Region Configuration

### Steps:
1. Click on the region selector (top-right corner)
2. Select your assigned region: **ap-southeast-1** (Singapore)
3. Verify region is displayed correctly

### Important:
⚠️ **All subsequent resources MUST be created in this region**

### Screenshot Required:
📸 **Screenshot 2:** Region selector showing ap-southeast-1 selected

---

## Task 3: Network Configuration

### 3.1: Create VPC

**Navigate:** VPC Dashboard → Your VPCs → Create VPC

**Configuration:**
```
Name: vpc-capstone1 (replace with your IAM name)
IPv4 CIDR: 10.1.0.0/16 (replace 1 with your group number)
IPv6 CIDR: No IPv6 CIDR block
Tenancy: Default
Tags: Name = vpc-capstone1
```

**Click:** Create VPC

### Screenshot Required:
📸 **Screenshot 3:** VPC created successfully

---

### 3.2: Create Subnets

#### Subnet 1 (Public - Web Servers - AZ-a)

**Navigate:** VPC Dashboard → Subnets → Create subnet

```
VPC: vpc-capstone1
Subnet name: subnet-1
Availability Zone: ap-southeast-1a
IPv4 CIDR: 10.1.0.0/25
```

#### Subnet 2 (Public - HA Web Servers - AZ-b)

```
VPC: vpc-capstone1
Subnet name: subnet-2
Availability Zone: ap-southeast-1b
IPv4 CIDR: 10.1.0.128/27
```

#### Subnet 3 (Public - Management - AZ-c)

```
VPC: vpc-capstone1
Subnet name: subnet-3
Availability Zone: ap-southeast-1c
IPv4 CIDR: 10.1.0.160/28
```

#### Subnet 4 (Private - Cloud Server - AZ-a)

```
VPC: vpc-capstone1
Subnet name: subnet-4
Availability Zone: ap-southeast-1a
IPv4 CIDR: 10.1.0.176/28
```

**Click:** Create subnet (for each)

### Screenshot Required:
📸 **Screenshot 4:** All 4 subnets created

---

### 3.3: Create Internet Gateway

**Navigate:** VPC Dashboard → Internet Gateways → Create internet gateway

```
Name: igw-capstone1
```

**After creation:**
- Select the IGW
- Actions → Attach to VPC
- Select: vpc-capstone1
- Attach internet gateway

### Screenshot Required:
📸 **Screenshot 5:** Internet Gateway attached to VPC

---

### 3.4: Create Route Table (for Public Subnets)

**Navigate:** VPC Dashboard → Route Tables → Create route table

```
Name: rtb-public-capstone1
VPC: vpc-capstone1
```

**After creation:**
1. Select the route table
2. **Routes tab** → Edit routes → Add route
   ```
   Destination: 0.0.0.0/0
   Target: igw-capstone1
   ```
3. Save changes

4. **Subnet associations tab** → Edit subnet associations
   - Select: subnet-1, subnet-2, subnet-3
   - Save associations

### Screenshot Required:
📸 **Screenshot 6:** Route table with IGW route and subnet associations

---

### 3.5: Enable Auto-assign Public IP (for public subnets)

For **subnet-1, subnet-2, subnet-3:**
1. Select subnet
2. Actions → Edit subnet settings
3. ✅ Enable auto-assign public IPv4 address
4. Save

### Screenshot Required:
📸 **Screenshot 7:** Auto-assign public IP enabled

---

### 3.6: Create Security Group

**Navigate:** EC2 Dashboard → Security Groups → Create security group

```
Security group name: secgroup-capstone1
Description: Security group for WordPress and Cloud Server
VPC: vpc-capstone1
```

**Inbound Rules:**

| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| SSH | TCP | 22 | 0.0.0.0/0 | SSH access |
| HTTP | TCP | 80 | 0.0.0.0/0 | Web traffic |
| HTTPS | TCP | 443 | 0.0.0.0/0 | Secure web |
| MySQL/Aurora | TCP | 3306 | 10.1.0.0/16 | Database access |
| All ICMP - IPv4 | ICMP | All | 10.1.0.0/16 | Ping within VPC |
| NFS | TCP | 2049 | 10.1.0.0/16 | EFS access |

**Outbound Rules:** Allow all traffic (default)

**Click:** Create security group

### Screenshot Required:
📸 **Screenshot 8:** Security group with all inbound rules

---

### 3.7: Allocate Elastic IP

**Navigate:** EC2 Dashboard → Elastic IPs → Allocate Elastic IP address

```
Network Border Group: ap-southeast-1
Public IPv4 address pool: Amazon's pool of IPv4 addresses
```

**Click:** Allocate

**Note:** Save this EIP address - you'll associate it with webserver later

### Screenshot Required:
📸 **Screenshot 9:** Elastic IP allocated

---

## Task 4: IP Subnetting Table

See the separate file **project7-ip-subnetting.md** for the complete solution.

Include this table in your report:

| Subnet | Network Address | First Usable | Last Usable | Broadcast Address |
|--------|----------------|--------------|-------------|-------------------|
| Subnet 1 | 10.1.0.0 | 10.1.0.1 | 10.1.0.126 | 10.1.0.127 |
| Subnet 2 | 10.1.0.128 | 10.1.0.129 | 10.1.0.158 | 10.1.0.159 |
| Subnet 3 | 10.1.0.160 | 10.1.0.161 | 10.1.0.174 | 10.1.0.175 |
| Subnet 4 | 10.1.0.176 | 10.1.0.177 | 10.1.0.190 | 10.1.0.191 |

---

## Task 5: EC2 Configuration

### 5.1: Create Key Pair (if not exists)

**Navigate:** EC2 Dashboard → Key Pairs → Create key pair

```
Name: Keypair-capstone1
Key pair type: RSA
Private key file format: .pem (for SSH) or .ppk (for PuTTY)
```

**Download** the private key and save securely!

### Screenshot Required:
📸 **Screenshot 10:** Key pair created

---

### 5.2: Launch Cloud Server EC2

**Navigate:** EC2 Dashboard → Instances → Launch instances

```
Name: cloudserver-capstone1
AMI: Amazon Linux 2 Kernel 5.10 AMI
Architecture: 64-bit (x86)
Instance type: t2.micro
Key pair: Keypair-capstone1

Network settings:
  VPC: vpc-capstone1
  Subnet: subnet-4 (PRIVATE)
  Auto-assign public IP: Disable
  Security group: secgroup-capstone1

Storage: 8 GB gp2 (default)
```

**Click:** Launch instance

### Screenshot Required:
📸 **Screenshot 11:** cloudserver-capstone1 running

---

### 5.3: Launch Web Server EC2

**Navigate:** EC2 Dashboard → Instances → Launch instances

```
Name: webserver-capstone1
AMI: Amazon Linux 2 Kernel 5.10 AMI
Architecture: 64-bit (x86)
Instance type: t2.micro
Key pair: Keypair-capstone1

Network settings:
  VPC: vpc-capstone1
  Subnet: subnet-1 (PUBLIC)
  Auto-assign public IP: Disable (we'll use Elastic IP)
  Security group: secgroup-capstone1

Storage: 8 GB gp2 (default)
```

**Click:** Launch instance

**After launch:**
1. Select webserver-capstone1
2. Actions → Networking → Manage IP addresses
3. Or: Elastic IPs → Select your EIP → Actions → Associate Elastic IP address
4. Choose: webserver-capstone1
5. Associate

### Screenshot Required:
📸 **Screenshot 12:** webserver-capstone1 running with Elastic IP

---

## Task 6: Web Server Configuration

### 6.1: Connect to Web Server

```bash
# Using SSH
chmod 400 Keypair-capstone1.pem
ssh -i "Keypair-capstone1.pem" ec2-user@<WEBSERVER-ELASTIC-IP>
```

### Screenshot Required:
📸 **Screenshot 13:** Connected to webserver via SSH

---

### 6.2: Update System

```bash
sudo yum update -y
```

---

### 6.3: Install NGINX

```bash
# Install NGINX
sudo amazon-linux-extras install nginx1 -y

# Start and enable NGINX
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify
sudo systemctl status nginx
```

### Screenshot Required:
📸 **Screenshot 14:** NGINX installed and running

---

### 6.4: Install PHP-FPM

```bash
# Install PHP 7.4 and modules
sudo amazon-linux-extras enable php7.4
sudo yum clean metadata
sudo yum install php php-fpm php-mysqlnd php-json php-gd php-mbstring php-xml -y

# Configure PHP-FPM for NGINX
sudo sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf
sudo sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf

# Start and enable PHP-FPM
sudo systemctl start php-fpm
sudo systemctl enable php-fpm

# Verify
sudo systemctl status php-fpm
```

### Screenshot Required:
📸 **Screenshot 15:** PHP-FPM installed and running

---

### 6.5: Install MySQL Client

```bash
sudo yum install mysql -y

# Verify
mysql --version
```

---

### 6.6: Download WordPress

```bash
# Navigate to web root
cd /usr/share/nginx/html

# Download WordPress
sudo wget https://wordpress.org/latest.tar.gz

# Extract
sudo tar -xzf latest.tar.gz

# Set permissions
sudo chown -R nginx:nginx /usr/share/nginx/html/wordpress
sudo chmod -R 755 /usr/share/nginx/html/wordpress

# Clean up
sudo rm latest.tar.gz
```

### Screenshot Required:
📸 **Screenshot 16:** WordPress files downloaded and extracted

---

### 6.7: Configure NGINX for WordPress

```bash
# Create NGINX configuration for WordPress
sudo nano /etc/nginx/conf.d/wordpress.conf
```

**Add this configuration:**

```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    location /wordpress {
        try_files $uri $uri/ /wordpress/index.php?$args;
    }
    
    location ~ ^/wordpress/.*\.php$ {
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

**Save and exit** (Ctrl+O, Enter, Ctrl+X)

```bash
# Test NGINX configuration
sudo nginx -t

# Restart NGINX
sudo systemctl restart nginx
```

### Screenshot Required:
📸 **Screenshot 17:** NGINX configuration successful

---

## Task 7: RDS Configuration

### 7.1: Create RDS Database

**Navigate:** RDS Dashboard → Databases → Create database

```
Database creation method: Standard create
Engine: MySQL
Version: MySQL 8.0.28
Templates: Free tier

Settings:
  DB instance identifier: database-capstone1
  Master username: root
  Master password: [Your strong password]
  Confirm password: [Same password]

Instance configuration: db.t3.micro

Connectivity:
  Compute resource: Connect to an EC2 compute resource
  EC2 instance: webserver-capstone1
  
  Network type: IPv4
  VPC: vpc-capstone1
  DB subnet group: Automatic setup
  Public access: No
  
  VPC security group: Choose existing
  Existing VPC security groups: secgroup-capstone1
  Availability Zone: ap-southeast-1a

Database authentication: Password authentication

Additional configuration:
  Initial database name: wordpress
  Backup retention period: 7 days
  Enable automated backups: Yes
  Enable encryption: No (for free tier)
```

**Click:** Create database

**Wait 5-10 minutes** for database to be available

### Screenshot Required:
📸 **Screenshot 18:** RDS database creating/available

---

### 7.2: Get RDS Endpoint

1. Select your database: database-capstone1
2. Copy the **Endpoint** (looks like: database-capstone1.xxxxx.ap-southeast-1.rds.amazonaws.com)
3. Save this - you'll need it for WordPress installation

### Screenshot Required:
📸 **Screenshot 19:** RDS endpoint displayed

---

## Task 8: WordPress Installation

### 8.1: Get Database Private IP (Optional)

From webserver, run:

```bash
nslookup [RDS-ENDPOINT]
# Example: nslookup database-capstone1.xxxxx.ap-southeast-1.rds.amazonaws.com
```

Note the private IP address

---

### 8.2: Access WordPress Setup

**In your browser:**
```
http://[WEBSERVER-ELASTIC-IP]/wordpress
```

You should see the WordPress setup page.

### Screenshot Required:
📸 **Screenshot 20:** WordPress language selection page

---

### 8.3: Configure WordPress Database Connection

**Click:** Let's go!

**Enter:**
```
Database Name: wordpress
Username: root
Password: [Your RDS master password]
Database Host: [RDS-ENDPOINT]
           or: [RDS-PRIVATE-IP]
Table Prefix: wp_
```

**Click:** Submit

### Screenshot Required:
📸 **Screenshot 21:** WordPress database configuration page

---

### 8.4: Run Installation

**Click:** Run the installation

**Enter Site Information:**
```
Site Title: [Your site name, e.g., "Capstone WordPress"]
Username: [Your WordPress admin username]
Password: [Strong password]
Your Email: [Your email]
```

**Click:** Install WordPress

### Screenshot Required:
📸 **Screenshot 22:** WordPress installation success

---

### 8.5: Login to WordPress

**Login** with your credentials

### Screenshot Required:
📸 **Screenshot 23:** WordPress dashboard

---

## Task 9: S3 Static Website Hosting

### 9.1: Create S3 Bucket

**Navigate:** S3 Dashboard → Buckets → Create bucket

```
Bucket name: bucket-capstone1-[random-numbers]
  (must be globally unique, add random numbers)
AWS Region: ap-southeast-1
Object Ownership: ACLs disabled
Block Public Access settings: UNCHECK "Block all public access"
  ⚠️ Acknowledge that public access will be allowed
Bucket Versioning: Disable
Tags: (optional)
Default encryption: Disable
```

**Click:** Create bucket

### Screenshot Required:
📸 **Screenshot 24:** S3 bucket created

---

### 9.2: Create index.html

Create a file on your computer named **index.html**:

```html
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>My Capstone Project Home Page</title>
</head>
<body>
    <h1>Welcome to my capstone-capstone1 website</h1>
    <p>Creator of this page: [Your Full Name]</p>
    <p>Now hosted on Amazon S3!</p>
</body>
</html>
```

---

### 9.3: Create error.html

Create **error.html**:

```html
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Error Page</title>
</head>
<body>
    <h1>Oops! Page Not Found</h1>
    <p>The page you are looking for does not exist.</p>
</body>
</html>
```

---

### 9.4: Upload Files

1. Select your bucket
2. Click **Upload**
3. **Add files:** index.html and error.html
4. Click **Upload**

### Screenshot Required:
📸 **Screenshot 25:** Files uploaded to S3

---

### 9.5: Enable Static Website Hosting

1. Select your bucket
2. Go to **Properties** tab
3. Scroll to **Static website hosting**
4. Click **Edit**

```
Static website hosting: Enable
Hosting type: Host a static website
Index document: index.html
Error document: error.html
```

5. **Save changes**
6. **Note the website endpoint URL** (e.g., http://bucket-capstone1-123.s3-website-ap-southeast-1.amazonaws.com)

### Screenshot Required:
📸 **Screenshot 26:** Static website hosting enabled

---

### 9.6: Configure Bucket Policy

1. Go to **Permissions** tab
2. Scroll to **Bucket policy**
3. Click **Edit**

**Paste this policy** (replace YOUR-BUCKET-NAME):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
        }
    ]
}
```

4. **Save changes**

---

### 9.7: Test Website

Visit the S3 website endpoint URL in your browser

### Screenshot Required:
📸 **Screenshot 27:** S3 static website displaying your page

---

## Task 10: NAT Gateway Configuration

### 10.1: Create NAT Gateway

**Navigate:** VPC Dashboard → NAT Gateways → Create NAT gateway

```
Name: natg-capstone1
Subnet: subnet-1 (any public subnet)
Connectivity type: Public
Elastic IP allocation ID: [Allocate new Elastic IP]
```

**Click:** Create NAT gateway

**Wait 2-3 minutes** for state to become "Available"

### Screenshot Required:
📸 **Screenshot 28:** NAT Gateway available

---

### 10.2: Create Route Table for Private Subnet

**Navigate:** VPC Dashboard → Route Tables → Create route table

```
Name: rtb-private-capstone1
VPC: vpc-capstone1
```

**After creation:**
1. Select the route table
2. **Routes tab** → Edit routes → Add route
   ```
   Destination: 0.0.0.0/0
   Target: natg-capstone1
   ```
3. Save changes

4. **Subnet associations tab** → Edit subnet associations
   - Select: subnet-4
   - Save associations

### Screenshot Required:
📸 **Screenshot 29:** Private route table with NAT Gateway

---

### 10.3: Test Internet Access from Cloud Server

You'll need a bastion host or Session Manager to access cloudserver (in private subnet)

**Alternative:** Temporarily add a route to cloudserver's subnet or create an Instance Connect Endpoint

For now, this will be tested after EFS setup when you connect via webserver as a jump host.

---

## Task 11: EFS Configuration

### 11.1: Create EFS File System

**Navigate:** EFS Dashboard → File systems → Create file system

**Click:** Customize

```
Name: efs-capstone1
Availability and Durability: Regional
Automatic backups: Disabled
Lifecycle management: None
Performance mode: General Purpose
Throughput mode: Bursting
Encryption: Disabled (for simplicity)
```

**Click:** Next

**Network settings:**
```
VPC: vpc-capstone1

Mount targets:
  Availability zone: ap-southeast-1a
  Subnet ID: subnet-4
  Security groups: secgroup-capstone1
  
  (You can add more AZs later for HA)
```

**Click:** Next → Next → Create

### Screenshot Required:
📸 **Screenshot 30:** EFS file system created

---

### 11.2: Mount EFS on Cloud Server

**Note:** Since cloudserver is in private subnet, SSH via webserver as jump host:

```bash
# From your computer, SSH to webserver
ssh -i "Keypair-capstone1.pem" ec2-user@[WEBSERVER-ELASTIC-IP]

# From webserver, SSH to cloudserver using private IP
ssh ec2-user@[CLOUDSERVER-PRIVATE-IP]
```

**On cloudserver:**

```bash
# Install NFS utilities
sudo yum install -y amazon-efs-utils

# Create mount point
sudo mkdir /mnt/efs

# Get EFS file system ID from console (fs-xxxxx)
# Mount EFS using IP
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport [EFS-ID].efs.ap-southeast-1.amazonaws.com:/ /mnt/efs

# Verify mount
df -h | grep efs
```

---

### 11.3: Create Test File

```bash
# Create a text file with cloudserver name
sudo touch /mnt/efs/cloudserver-capstone1.txt
echo "Created by cloudserver-capstone1" | sudo tee /mnt/efs/cloudserver-capstone1.txt

# List files
ls -la /mnt/efs/
cat /mnt/efs/cloudserver-capstone1.txt
```

### Screenshot Required:
📸 **Screenshot 31:** EFS mounted and test file created

---

### 11.4: Verify from Another Instance (Optional)

You can verify by mounting the same EFS on webserver:

```bash
# On webserver
sudo yum install -y amazon-efs-utils
sudo mkdir /mnt/efs-test
sudo mount -t nfs4 -o nfsvers=4.1 [EFS-ID].efs.ap-southeast-1.amazonaws.com:/ /mnt/efs-test
cat /mnt/efs-test/cloudserver-capstone1.txt
```

This confirms EFS is shared across instances!

---

## Task 12: VPC Peering

**Note:** This requires coordination with another student in a different region

### 12.1: Create VPC Peering Connection

**Navigate:** VPC Dashboard → Peering connections → Create peering connection

```
Name: vpn-capstone1-to-[other-region]
VPC (Requester): vpc-capstone1
Account: My account (or specify other account)
Region: Another region
VPC (Accepter): [Other VPC ID in different region]
```

**Click:** Create peering connection

---

### 12.2: Accept Peering (if you're the accepter)

1. Switch to the accepter region
2. VPC Dashboard → Peering connections
3. Select the pending peering connection
4. Actions → Accept request

---

### 12.3: Update Route Tables

**In BOTH regions:**

1. Go to Route Tables
2. Select your private route table
3. Routes → Edit routes → Add route
   ```
   Destination: [Other VPC CIDR, e.g., 10.2.0.0/16]
   Target: [Peering connection ID]
   ```

---

### 12.4: Test Connectivity

From your cloudserver, ping the other region's cloudserver:

```bash
ping [OTHER-CLOUDSERVER-PRIVATE-IP]
```

### Screenshot Required:
📸 **Screenshot 32:** Successful ping across VPC peering

---

# PART 4: HIGH AVAILABILITY

## Task 1: Create AMI from Web Server

### 1.1: Stop WordPress Webserver

**Navigate:** EC2 Dashboard → Instances

1. Select webserver-capstone1
2. Instance state → Stop instance
3. Wait until state = "Stopped"

---

### 1.2: Create Image

1. Select webserver-capstone1 (stopped)
2. Actions → Image and templates → Create image

```
Image name: img-capstone1
Image description: WordPress web server image for auto scaling
No reboot: Checked (already stopped)
Instance volumes: (default)
Tags: Name = img-capstone1
```

**Click:** Create image

**Wait 3-5 minutes** for AMI to be available

### Screenshot Required:
📸 **Screenshot 33:** AMI created successfully

---

### 1.3: Start Webserver Again

After AMI is created, you can start webserver-capstone1 again if needed

---

## Task 2: Auto Scaling & Load Balancer

### 2.1: Create Launch Template

**Navigate:** EC2 Dashboard → Launch Templates → Create launch template

```
Launch template name: lt-capstone1
Template version description: WordPress launch template
Auto Scaling guidance: ✅ Checked

Amazon Machine Image (AMI): img-capstone1
Instance type: t2.micro
Key pair: Keypair-capstone1

Network settings:
  Don't include in launch template (will specify in ASG)
  
Security groups: secgroup-capstone1

Advanced details:
  (Leave defaults)
```

**Click:** Create launch template

### Screenshot Required:
📸 **Screenshot 34:** Launch template created

---

### 2.2: Create Target Group (for ALB)

**Navigate:** EC2 Dashboard → Target Groups → Create target group

```
Target type: Instances
Target group name: cluster-capstone1
Protocol: HTTP
Port: 80
VPC: vpc-capstone1

Health checks:
  Protocol: HTTP
  Path: /wordpress/
  
Advanced health check settings:
  Healthy threshold: 2
  Unhealthy threshold: 2
  Timeout: 5
  Interval: 30
```

**Click:** Next

**Do NOT register targets** (Auto Scaling will do this)

**Click:** Create target group

### Screenshot Required:
📸 **Screenshot 35:** Target group created

---

### 2.3: Create Application Load Balancer

**Navigate:** EC2 Dashboard → Load Balancers → Create load balancer

**Select:** Application Load Balancer

```
Load balancer name: lb-capstone1
Scheme: Internet-facing
IP address type: IPv4

Network mapping:
  VPC: vpc-capstone1
  Mappings: 
    ✅ ap-southeast-1a → subnet-1
    ✅ ap-southeast-1b → subnet-2
    ✅ ap-southeast-1c → subnet-3
    (All public subnets, NOT subnet-4)

Security groups: secgroup-capstone1

Listeners and routing:
  Protocol: HTTP
  Port: 80
  Default action: Forward to cluster-capstone1
```

**Click:** Create load balancer

**Wait 2-3 minutes** for state = "Active"

**Note the DNS name** (lb-capstone1-xxxxx.ap-southeast-1.elb.amazonaws.com)

### Screenshot Required:
📸 **Screenshot 36:** Load balancer active

---

### 2.4: Create Auto Scaling Group

**Navigate:** EC2 Dashboard → Auto Scaling Groups → Create Auto Scaling group

**Step 1: Choose launch template**
```
Auto Scaling group name: as-group-capstone1
Launch template: lt-capstone1
Version: Default
```

**Click:** Next

**Step 2: Choose instance launch options**
```
VPC: vpc-capstone1
Availability Zones and subnets:
  ✅ subnet-1 (ap-southeast-1a)
  ✅ subnet-2 (ap-southeast-1b)
  ✅ subnet-3 (ap-southeast-1c)
```

**Click:** Next

**Step 3: Configure advanced options**
```
Load balancing: Attach to an existing load balancer
  Choose from your load balancer target groups
  Existing load balancer target groups: cluster-capstone1

Health checks:
  ✅ Turn on Elastic Load Balancing health checks
  Health check grace period: 300 seconds
```

**Click:** Next

**Step 4: Configure group size and scaling**
```
Group size:
  Desired capacity: 2
  Minimum capacity: 0
  Maximum capacity: 3

Automatic scaling: No scaling policies
```

**Click:** Next

**Step 5: Add notifications** (Skip)

**Click:** Next

**Step 6: Add tags**
```
Key: Name
Value: asg-instance-capstone1
```

**Click:** Next

**Step 7: Review**

**Click:** Create Auto Scaling group

### Screenshot Required:
📸 **Screenshot 37:** Auto Scaling group created
📸 **Screenshot 38:** Instances being launched (2 instances)

---

## Task 3: Scaling Policy

### 3.1: Create Scheduled Action

**Navigate:** Auto Scaling Groups → Select as-group-capstone1 → Automatic scaling tab

**Click:** Create scheduled action

```
Name: scheduled-scale-capstone1
Desired capacity: 2
Min: 0
Max: 3
Recurrence: Once
Time zone: (UTC+08:00) Singapore
Start time: [2 minutes from now]
  Example: If current time is 14:30, set to 14:32
```

**Click:** Create

**Wait for the scheduled time** to verify scaling

### Screenshot Required:
📸 **Screenshot 39:** Scheduled action created
📸 **Screenshot 40:** Instances scaled to desired capacity (2)

---

## Task 4: Verify WordPress Connectivity

### 4.1: From Windows 10 Pro VM (Part 1)

**In your Windows 10 VM:**

1. Open browser
2. Navigate to: `http://[LOAD-BALANCER-DNS]/wordpress`
   
   Example: `http://lb-capstone1-123456.ap-southeast-1.elb.amazonaws.com/wordpress`

3. You should see your WordPress site!

### Screenshot Required:
📸 **Screenshot 41:** WordPress accessible via Load Balancer from Windows VM
📸 **Screenshot 42:** WordPress login page via Load Balancer
📸 **Screenshot 43:** WordPress dashboard accessed via Load Balancer

---

### 4.2: Verify High Availability

**Test failover:**

1. **Terminate one instance** from Auto Scaling group
2. **Refresh your browser** - WordPress should still work!
3. **Auto Scaling will launch a replacement** instance automatically
4. **Wait 2-3 minutes** - desired capacity (2) will be restored

### Screenshot Required:
📸 **Screenshot 44:** Instance termination and auto-replacement

---

# Completion Checklist

## Part 3: AWS Resources (12 Tasks)

- [x] Task 1: IAM Sign-in
- [x] Task 2: Region Configuration
- [x] Task 3: Network Configuration (VPC, Subnets, IGW, Routes, Security Group, EIP)
- [x] Task 4: IP Subnetting Table
- [x] Task 5: EC2 Configuration (2 instances)
- [x] Task 6: Web Server Configuration (NGINX, PHP, WordPress files)
- [x] Task 7: RDS Configuration (MySQL database)
- [x] Task 8: WordPress Installation
- [x] Task 9: S3 Static Website Hosting
- [x] Task 10: NAT Gateway
- [x] Task 11: EFS Configuration
- [x] Task 12: VPC Peering

## Part 4: High Availability (4 Tasks)

- [x] Task 1: AMI Image Creation
- [x] Task 2: Auto Scaling & Load Balancer
- [x] Task 3: Scaling Policy
- [x] Task 4: Connectivity Verification

---

# Total Screenshots Required: 44+

Make sure all screenshots are:
✅ Clear and readable  
✅ Show relevant information  
✅ Include AWS console URL/navigation  
✅ Have captions describing what's shown  

---

**Congratulations! You've completed the AWS WordPress High Availability deployment!** 🎉
