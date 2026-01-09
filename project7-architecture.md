# Project 7 - Architecture Overview

## AWS High Availability WordPress Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          INTERNET                               │
└────────────────────────┬────────────────────────────────────────┘
                         │
              ┌──────────▼──────────┐
              │  Internet Gateway   │
              │   igw-capstone1     │
              └──────────┬──────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
┌───────▼────────┐ ┌────▼──────┐ ┌──────▼────────┐
│   Subnet-1     │ │ Subnet-2  │ │  Subnet-3     │
│   (Public)     │ │ (Public)  │ │  (Public)     │
│ 10.1.0.0/25    │ │10.1.0.128 │ │ 10.1.0.160/28 │
│   AZ-1a        │ │   AZ-1b   │ │    AZ-1c      │
│  70 hosts      │ │  30 hosts │ │   10 hosts    │
└────────┬───────┘ └─────┬─────┘ └───────┬───────┘
         │               │                │
    ┌────▼───────────────▼────────────────▼──────┐
    │      Application Load Balancer (ALB)       │
    │            lb-capstone1                    │
    │         (Internet-facing)                  │
    └────────────────┬───────────────────────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
    ┌────▼────┐ ┌───▼─────┐ ┌──▼──────┐
    │   EC2   │ │   EC2   │ │  EC2    │
    │WordPress│ │WordPress│ │WordPress│
    │Instance │ │Instance │ │Instance │
    │   #1    │ │   #2    │ │  #3     │
    └────┬────┘ └────┬────┘ └────┬────┘
         │           │            │
    ┌────▼───────────▼────────────▼──────┐
    │    Auto Scaling Group (ASG)        │
    │     as-group-capstone1             │
    │  Min: 0  Desired: 2  Max: 3        │
    └────────────────────────────────────┘
                     │
                     │
         ┌───────────▼────────────┐
         │                        │
    ┌────▼──────┐        ┌───────▼──────┐
    │    RDS    │        │     EFS      │
    │   MySQL   │        │ File System  │
    │ Multi-AZ  │        │              │
    │(Automatic)│        │efs-capstone1 │
    └───────────┘        └──────────────┘


┌──────────────────────────────────────────────────────────┐
│             PRIVATE SUBNET (Subnet-4)                    │
│              10.1.0.176/28 (AZ-1a)                       │
│                  10 hosts                                │
│                                                          │
│    ┌──────────────┐          ┌────────────────┐         │
│    │ Cloud Server │          │  NAT Gateway   │         │
│    │cloudserver-  │◄─────────│  natg-capstone1│         │
│    │  capstone1   │ Internet │  (in subnet-1) │         │
│    └──────┬───────┘  Access  └────────────────┘         │
│           │                                              │
│           │ Mounted                                      │
│           ▼                                              │
│    ┌──────────────┐                                     │
│    │  EFS Mount   │                                     │
│    │/mnt/efs      │                                     │
│    └──────────────┘                                     │
└──────────────────────────────────────────────────────────┘


┌──────────────────────────────────────────────────────────┐
│              ADDITIONAL COMPONENTS                       │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  S3 Static Website                VPC Peering           │
│  ┌────────────────┐              ┌─────────────┐        │
│  │  S3 Bucket     │              │vpc-capstone1│        │
│  │bucket-capstone1│              │      ↕      │        │
│  │                │              │vpc-[other   │        │
│  │ index.html     │              │   region]   │        │
│  │ error.html     │              └─────────────┘        │
│  └────────────────┘                                     │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Network Flow

### User Access to WordPress
```
User → Internet → Internet Gateway → ALB → 
  WordPress Instance (Random) → RDS MySQL Database
```

### High Availability Features
1. **Application Load Balancer** - Distributes traffic across multiple AZs
2. **Auto Scaling Group** - Maintains 2 instances, scales up to 3 if needed
3. **Multi-AZ RDS** - Automatic failover for database
4. **EFS** - Shared file system across instances
5. **Multiple Availability Zones** - Subnets in ap-southeast-1a, 1b, 1c

### Private Resource Internet Access
```
Cloud Server → NAT Gateway → Internet Gateway → Internet
```

---

## IP Address Summary

### VPC CIDR: 10.1.0.0/16

| Resource | IP Range | Type | Purpose |
|----------|----------|------|---------|
| Subnet-1 | 10.1.0.0/25 | Public | Web servers (126 IPs) |
| Subnet-2 | 10.1.0.128/27 | Public | HA web servers (30 IPs) |
| Subnet-3 | 10.1.0.160/28 | Public | Management (14 IPs) |
| Subnet-4 | 10.1.0.176/28 | Private | Cloud server (14 IPs) |

---

## Components List

### Networking
- [x] VPC (vpc-capstone1): 10.1.0.0/16
- [x] 4 Subnets across 3 AZs
- [x] Internet Gateway (igw-capstone1)
- [x] 2 Route Tables (public & private)
- [x] NAT Gateway (natg-capstone1)
- [x] Security Group (secgroup-capstone1)
- [x] 2 Elastic IPs (webserver + NAT)

### Compute
- [x] Launch Template (lt-capstone1)
- [x] Auto Scaling Group (as-group-capstone1)
- [x] Application Load Balancer (lb-capstone1)
- [x] Target Group (cluster-capstone1)
- [x] Cloud Server EC2 (cloudserver-capstone1)
- [x] 2-3 WordPress EC2 instances (auto-scaled)

### Storage & Database
- [x] RDS MySQL 8.0.28 (database-capstone1)
- [x] EFS File System (efs-capstone1)
- [x] S3 Static Website (bucket-capstone1)

### HA Features
- [x] Multi-AZ deployment
- [x] Auto Scaling (0-3 instances)
- [x] Load balancing
- [x] Health checks
- [x] Scheduled scaling policy

---

## Security Configuration

### Security Group Rules (secgroup-capstone1)

**Inbound:**
- SSH (22) - From anywhere (for management)
- HTTP (80) - From anywhere (web traffic)
- HTTPS (443) - From anywhere (secure web)
- MySQL (3306) - From VPC only (database)
- NFS (2049) - From VPC only (EFS)
- ICMP - From VPC only (ping)

**Outbound:**
- All traffic allowed

---

## High Availability Testing

### Test Scenarios

1. **Instance Failure**
   - Terminate 1 instance
   - ALB redirects traffic to healthy instance
   - ASG launches replacement
   - Service continues without interruption

2. **AZ Failure**
   - If AZ-1a fails
   - ALB routes to instances in AZ-1b and AZ-1c
   - Application remains available

3. **Database Failover**
   - RDS Multi-AZ automatically fails over
   - Connection string stays same
   - ~60 seconds downtime max

4. **Scaling Event**
   - Load increases
   - ASG scales from 2 to 3 instances
   - New instance added to ALB
   - Traffic distributed across 3 instances

---

## Access Points

### Public Endpoints
1. **WordPress Site**: http://[ALB-DNS]/wordpress
2. **S3 Website**: http://[bucket-name].s3-website-[region].amazonaws.com
3. **Individual Web Server**: http://[ELASTIC-IP]/wordpress

### Private Resources
- Cloud Server: 10.1.0.177 (example)
- RDS Database: database-capstone1.[xxx].rds.amazonaws.com
- EFS Mount: efs-capstone1.efs.ap-southeast-1.amazonaws.com

---

## Cost Estimate (Free Tier)

**Within Free Tier:**
- 750 hours EC2 t2.micro/month
- 750 hours RDS db.t3.micro/month
- 5GB S3 storage
- 750 hours ALB/month

**Paid (if exceeded):**
- NAT Gateway: ~$0.045/hour + data transfer
- EFS: ~$0.30/GB/month
- Additional EC2/RDS hours
- Data transfer costs

**Monthly estimate**: $10-30 depending on usage

---

## Maintenance Tasks

### Daily
- Monitor CloudWatch metrics
- Check Auto Scaling activity
- Review ALB health checks

### Weekly
- Review security group rules
- Check WordPress updates
- Monitor costs in Billing Dashboard

### Monthly
- Review and rotate passwords
- Update WordPress and plugins
- Backup verification
- Clean up unused resources

---

## Troubleshooting Guide

### WordPress Not Accessible
1. Check ALB status (should be "active")
2. Verify target group has healthy instances
3. Check security group allows HTTP (80)
4. Verify instances are running
5. Check NGINX and PHP-FPM status on instances

### Database Connection Error
1. Verify RDS is "available"
2. Check security group allows MySQL (3306)
3. Verify wp-config.php has correct endpoint
4. Test connection: `mysql -h [RDS-endpoint] -u root -p`

### Auto Scaling Not Working
1. Check desired capacity matches instance count
2. Verify launch template is correct
3. Check ASG health check grace period
4. Review CloudWatch logs

### No Internet from Cloud Server
1. Verify NAT Gateway is "available"
2. Check private route table has NAT route
3. Verify security group allows outbound
4. Test: `ping 8.8.8.8` from cloudserver

---

**This architecture provides enterprise-grade high availability for WordPress!** 🚀
