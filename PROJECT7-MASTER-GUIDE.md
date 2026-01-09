# Project 7: AWS High Availability WordPress Deployment
## Master Execution Guide

**Student**: Chee Young Chang
**IAM Name**: cheeyoung
**AWS Region**: ap-southeast-1 (Singapore)
**VPC CIDR**: 10.1.0.0/16
**Date**: January 2026

---

## Project Overview

Build a highly available WordPress web server on AWS with auto-scaling capabilities, demonstrating enterprise-grade cloud architecture for Acme Corporation.

### Deliverables

1. **Windows 10 Pro VM** (VMware Workstation) with network documentation
2. **CentOS 7.6 VM** (VMware Workstation) with network documentation
3. **WordPress Webserver** (AWS EC2 with NGINX, PHP-FPM, MySQL/RDS)
4. **Cloud Server** (AWS EC2 in private subnet)
5. **High Availability Setup** (Auto Scaling Group, Application Load Balancer)
6. **Complete Report** with 44+ screenshots, IP subnetting table, architecture diagram

---

## Resource Naming Convention

All AWS resources use the pattern: `[resource-type]-cheeyoung`

| Resource | Name |
|----------|------|
| VPC | vpc-cheeyoung |
| Subnets | subnet-1, subnet-2, subnet-3, subnet-4 |
| Internet Gateway | igw-cheeyoung |
| Route Table | rtb-cheeyoung |
| Security Group | secgroup-cheeyoung |
| Key Pair | keypair-cheeyoung |
| EC2 Cloudserver | cloudserver-cheeyoung |
| EC2 Webserver | webserver-cheeyoung |
| RDS Database | database-cheeyoung |
| S3 Bucket | bucket-cheeyoung |
| NAT Gateway | natg-cheeyoung |
| EFS | efs-cheeyoung |
| VPC Peering | vpn-cheeyoung |
| AMI | img-cheeyoung |
| Launch Template | as-config-cheeyoung |
| Auto Scaling Group | as-group-cheeyoung |
| Load Balancer | lb-cheeyoung |
| Target Group | cluster-cheeyoung |

---

## Project Timeline

### Phase 1: Local VM Setup (Parts 1 & 2)
**Time**: 3-4 hours

- [ ] Install Windows 10 Pro on VMware (1.5 hours)
- [ ] Install CentOS 7.6 on VMware (1.5 hours)
- [ ] Document network information for both VMs (1 hour)

### Phase 2: AWS Infrastructure (Part 3)
**Time**: 6-8 hours

- [ ] Tasks 1-4: VPC, Networking, IP Subnetting (2 hours)
- [ ] Tasks 5-6: EC2 instances and web server setup (2 hours)
- [ ] Tasks 7-8: RDS and WordPress installation (1.5 hours)
- [ ] Tasks 9-12: S3, NAT, EFS, VPC Peering (2.5 hours)

### Phase 3: High Availability (Part 4)
**Time**: 2-3 hours

- [ ] Create AMI and Launch Template (30 minutes)
- [ ] Configure Auto Scaling Group (1 hour)
- [ ] Setup Application Load Balancer (45 minutes)
- [ ] Create Scaling Policy and test (45 minutes)

### Phase 4: Documentation
**Time**: 2-3 hours

- [ ] Compile all 44+ screenshots with captions
- [ ] Add IP subnetting table
- [ ] Include architecture diagram
- [ ] Write executive summary and conclusions

**Total Estimated Time**: 13-18 hours

---

## Quick Reference: IP Subnetting Table (VLSM)

**Base Network**: 10.1.0.0/16

| Subnet | Network Address | First Usable | Last Usable | Broadcast | CIDR | Hosts Required | Usable Hosts |
|--------|----------------|--------------|-------------|-----------|------|----------------|--------------|
| subnet-1 | 10.1.0.0 | 10.1.0.1 | 10.1.0.126 | 10.1.0.127 | 10.1.0.0/25 | 70 | 126 |
| subnet-2 | 10.1.0.128 | 10.1.0.129 | 10.1.0.158 | 10.1.0.159 | 10.1.0.128/27 | 30 | 30 |
| subnet-3 | 10.1.0.160 | 10.1.0.161 | 10.1.0.174 | 10.1.0.175 | 10.1.0.160/28 | 10 | 14 |
| subnet-4 | 10.1.0.176 | 10.1.0.177 | 10.1.0.190 | 10.1.0.191 | 10.1.0.176/28 | 10 | 14 |

**Subnet Usage**:
- **subnet-1** (10.1.0.0/25): Public subnet for webserver (has route to Internet Gateway)
- **subnet-2** (10.1.0.128/27): Public subnet (multi-AZ for high availability)
- **subnet-3** (10.1.0.160/28): Public subnet (multi-AZ for high availability)
- **subnet-4** (10.1.0.176/28): Private subnet for cloudserver (route via NAT Gateway)

---

## Screenshot Checklist

### Part 1: Windows 10 Pro (3 screenshots)
- [ ] Screenshot 1.1: VMware installation process
- [ ] Screenshot 1.2: Windows 10 Pro powered on (showing desktop)
- [ ] Screenshot 1.3: Network information (ipconfig /all in Command Prompt)

### Part 2: CentOS 7.6 (2 screenshots)
- [ ] Screenshot 2.1: CentOS powered on (login screen or desktop)
- [ ] Screenshot 2.2: Network information display in CLI (ip addr, nmcli)

### Part 3: AWS Resources (32+ screenshots)
- [ ] Screenshot 3.1: AWS IAM Sign-in page
- [ ] Screenshot 3.2: AWS Console showing region ap-southeast-1
- [ ] Screenshot 3.3: VPC created (vpc-cheeyoung)
- [ ] Screenshot 3.4: 4 subnets created
- [ ] Screenshot 3.5: Internet Gateway (igw-cheeyoung)
- [ ] Screenshot 3.6: Route table configuration
- [ ] Screenshot 3.7: Security group rules
- [ ] Screenshot 3.8: Security group inbound rules details
- [ ] Screenshot 3.9: Elastic IP allocated
- [ ] Screenshot 3.10: Key pair created (keypair-cheeyoung)
- [ ] Screenshot 3.11: cloudserver-cheeyoung instance running
- [ ] Screenshot 3.12: webserver-cheeyoung instance running
- [ ] Screenshot 3.13: SSH connection to webserver
- [ ] Screenshot 3.14: NGINX installation
- [ ] Screenshot 3.15: PHP-FPM installation
- [ ] Screenshot 3.16: WordPress download
- [ ] Screenshot 3.17: NGINX configuration file
- [ ] Screenshot 3.18: RDS database creation settings
- [ ] Screenshot 3.19: RDS database running (database-cheeyoung)
- [ ] Screenshot 3.20: WordPress installation page
- [ ] Screenshot 3.21: WordPress database configuration
- [ ] Screenshot 3.22: WordPress installation complete
- [ ] Screenshot 3.23: WordPress dashboard
- [ ] Screenshot 3.24: S3 bucket created (bucket-cheeyoung)
- [ ] Screenshot 3.25: S3 bucket with index.html uploaded
- [ ] Screenshot 3.26: S3 bucket policy for public access
- [ ] Screenshot 3.27: S3 static website URL accessible
- [ ] Screenshot 3.28: NAT Gateway created
- [ ] Screenshot 3.29: NAT Gateway route configuration
- [ ] Screenshot 3.30: EFS created (efs-cheeyoung)
- [ ] Screenshot 3.31: EFS mounted on cloudserver
- [ ] Screenshot 3.32: VPC Peering connection

### Part 4: High Availability (12+ screenshots)
- [ ] Screenshot 4.1: AMI created (img-cheeyoung) from webserver
- [ ] Screenshot 4.2: Launch Template created (as-config-cheeyoung)
- [ ] Screenshot 4.3: Target Group created (cluster-cheeyoung)
- [ ] Screenshot 4.4: Application Load Balancer created (lb-cheeyoung)
- [ ] Screenshot 4.5: Load Balancer DNS name
- [ ] Screenshot 4.6: Auto Scaling Group created (as-group-cheeyoung)
- [ ] Screenshot 4.7: Auto Scaling Group configuration showing subnets
- [ ] Screenshot 4.8: Auto Scaling Group Activity showing instances launching
- [ ] Screenshot 4.9: Scheduled scaling policy created
- [ ] Screenshot 4.10: Scheduled scaling policy details (desired: 2, min: 0, max: 3)
- [ ] Screenshot 4.11: Windows 10 VM browser accessing Load Balancer URL
- [ ] Screenshot 4.12: WordPress site displayed via Load Balancer

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet                                 │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                  ┌────────▼────────┐
                  │   Application   │
                  │ Load Balancer   │
                  │  (lb-cheeyoung) │
                  └────────┬────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
┌───────▼──────┐  ┌────────▼──────┐  ┌───────▼──────┐
│   subnet-1   │  │   subnet-2    │  │   subnet-3   │
│  (Public)    │  │   (Public)    │  │   (Public)   │
│ 10.1.0.0/25  │  │ 10.1.0.128/27 │  │ 10.1.0.160/28│
│              │  │               │  │              │
│ Auto Scaling │  │ Auto Scaling  │  │ Auto Scaling │
│  Instances   │  │  Instances    │  │  Instances   │
│ (webservers) │  │ (webservers)  │  │ (webservers) │
└───────┬──────┘  └───────┬───────┘  └──────┬───────┘
        │                 │                  │
        └─────────────────┼──────────────────┘
                          │
                 ┌────────▼──────────┐
                 │  RDS MySQL        │
                 │ (database-        │
                 │   cheeyoung)      │
                 └───────────────────┘

┌──────────────────────────────────────────────────┐
│   subnet-4 (Private)                             │
│   10.1.0.176/28                                  │
│                                                  │
│  ┌──────────────────┐         ┌──────────────┐ │
│  │ cloudserver-     │────────▶│ NAT Gateway  │ │
│  │   cheeyoung      │         │              │ │
│  │                  │         └──────┬───────┘ │
│  │  EFS Mounted     │                │         │
│  └──────────────────┘                │         │
└──────────────────────────────────────┼─────────┘
                                       │
                              ┌────────▼────────┐
                              │ Internet        │
                              │ Gateway         │
                              └─────────────────┘
```

---

## Execution Order

### 1. Local VMs First (Critical for Part 4 testing)
Start with Parts 1 & 2 because you'll need the Windows 10 VM at the end to test the Load Balancer.

**Commands**:
```bash
# Follow PROJECT7-PART1-WINDOWS.md
# Follow PROJECT7-PART2-CENTOS.md
```

### 2. AWS Infrastructure (Part 3)
Execute tasks 1-12 in sequence as they have dependencies.

**Commands**:
```bash
# Follow PROJECT7-PART3-AWS-DEPLOYMENT.md
# Reference PROJECT7-IP-SUBNETTING.md for subnet details
```

### 3. High Availability Setup (Part 4)
Must complete Part 3 first, as Part 4 uses the webserver to create an AMI.

**Commands**:
```bash
# Follow PROJECT7-PART4-HIGH-AVAILABILITY.md
```

### 4. Final Report
Compile all screenshots, add IP subnetting table, include architecture diagram.

---

## Important Notes

### ⚠️ Cost Management
- Use **t2.micro** for EC2 (free tier eligible)
- Use **db.t3.micro** for RDS (free tier eligible)
- **Delete all resources** after project submission to avoid charges
- Expected cost: ~$10-20 for testing if done efficiently

### 📸 Screenshot Strategy
- Take screenshots **immediately** after each step
- Name screenshots systematically: `P3-T1-VPC-Created.png`, `P4-T1-AMI-Created.png`
- Include captions in your report explaining what each screenshot shows

### 🔑 Security
- **Save your keypair-cheeyoung.pem** file securely
- Set permissions: `chmod 400 keypair-cheeyoung.pem`
- Don't commit .pem files to git
- Use strong passwords for RDS

### 🌐 Connectivity
- Ensure subnet-1, subnet-2, subnet-3 have routes to Internet Gateway
- Ensure subnet-4 (private) has route to NAT Gateway
- Security group must allow HTTP (80), SSH (22), MySQL (3306)
- RDS security group must allow inbound from webserver security group

### 🔄 Testing Strategy
1. After Task 6: Test webserver via Elastic IP (http://ELASTIC_IP)
2. After Task 8: Test WordPress via Elastic IP (http://ELASTIC_IP/wordpress)
3. After Part 4: Test via Load Balancer DNS from Windows 10 VM

---

## Next Steps

1. **Start with Part 1**: Install Windows 10 Pro VM
2. **Then Part 2**: Install CentOS 7.6 VM
3. **Then Part 3**: AWS infrastructure (Tasks 1-12)
4. **Then Part 4**: High availability setup
5. **Finally**: Compile report with all screenshots

**Estimated completion time**: 13-18 hours over 3-4 days

Good luck! 🚀
