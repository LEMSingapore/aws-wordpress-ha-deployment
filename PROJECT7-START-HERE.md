# Project 7 - Quick Start Guide

## 🎉 What You Have

I've created **3 comprehensive documents** for your AWS High Availability WordPress project:

### 1. **project7-ip-subnetting.md** ✅
- Complete IP subnetting solution
- All 4 subnets calculated using VLSM
- Network addresses, usable ranges, broadcast addresses
- AWS CLI commands included
- Verification checklist

### 2. **project7-aws-deployment-guide.md** ✅
- **60+ page comprehensive guide**
- Step-by-step instructions for all 16 tasks
- Part 3: 12 AWS resource configuration tasks
- Part 4: 4 high availability tasks
- **44+ screenshot checkpoints**
- Every AWS console click documented
- All commands provided
- Configuration files included

### 3. **project7-architecture.md** ✅
- Visual architecture diagram
- Network flow documentation
- Component list
- Security configuration
- HA testing scenarios
- Troubleshooting guide

---

## ⏱️ Time Estimate

**Parts 1 & 2** (VMs): 3-4 hours
- Windows 10 VM installation: 1.5 hours
- CentOS VM installation: 1.5 hours
- Network configuration verification: 1 hour

**Part 3** (AWS Resources): 6-8 hours
- VPC and networking: 1.5 hours
- EC2 and web server setup: 2 hours
- RDS and WordPress: 1.5 hours
- S3, NAT, EFS, VPC Peering: 2 hours
- Screenshots and documentation: 1 hour

**Part 4** (High Availability): 2-3 hours
- AMI creation and testing: 30 minutes
- Auto Scaling setup: 1 hour
- Load balancer configuration: 45 minutes
- Testing and verification: 45 minutes

**Total: 11-15 hours**

---

## 🚀 How to Execute

### Phase 1: Parts 1 & 2 (VMware)

**Do these first if you haven't:**

1. **Install Windows 10 Pro on VMware**
   - Download Windows 10 ISO
   - Install in VMware Workstation
   - Capture network information
   - Take screenshots

2. **Install CentOS 7.6 on VMware**
   - Download CentOS minimal ISO
   - Install in VMware Workstation
   - Capture network information
   - Check firewall status
   - Take screenshots

**Save these VMs** - you'll need Windows 10 VM in Part 4 to test the final deployment!

---

### Phase 2: Part 3 (AWS Resources)

**Follow the deployment guide step-by-step:**

```bash
# Download the deployment guide
# Open: project7-aws-deployment-guide.md

# Start from Task 1 and work through Task 12
# Take screenshots at each checkpoint (44+ total)
```

**Key Tasks:**
1. ✅ IAM Sign-in (Screenshot 1)
2. ✅ Region: ap-southeast-1 (Screenshot 2)
3. ✅ Create VPC + 4 Subnets (Screenshots 3-4)
   - Use IP subnetting solution from project7-ip-subnetting.md
4. ✅ IGW, Route Tables, Security Group (Screenshots 5-8)
5. ✅ Allocate Elastic IP (Screenshot 9)
6. ✅ Create Key Pair (Screenshot 10)
7. ✅ Launch 2 EC2 instances (Screenshots 11-12)
8. ✅ Install NGINX, PHP, WordPress (Screenshots 13-17)
9. ✅ Create RDS MySQL (Screenshots 18-19)
10. ✅ Install WordPress (Screenshots 20-23)
11. ✅ S3 Static Website (Screenshots 24-27)
12. ✅ NAT Gateway (Screenshots 28-29)
13. ✅ EFS File System (Screenshots 30-31)
14. ✅ VPC Peering (Screenshot 32)

**Track your progress** using the deployment guide checkpoints!

---

### Phase 3: Part 4 (High Availability)

**Configure Auto Scaling and Load Balancer:**

1. ✅ Stop webserver and create AMI (Screenshot 33)
2. ✅ Create Launch Template (Screenshot 34)
3. ✅ Create Target Group (Screenshot 35)
4. ✅ Create ALB (Screenshot 36)
5. ✅ Create Auto Scaling Group (Screenshots 37-38)
6. ✅ Scheduled scaling policy (Screenshots 39-40)
7. ✅ Test from Windows VM (Screenshots 41-44)

---

### Phase 4: Documentation & Submission

**Create your final report:**

1. **Compile all screenshots** (44+ from Parts 3 & 4, plus Parts 1 & 2)
2. **Add captions** to each screenshot
3. **Fill in IP subnetting table** (copy from project7-ip-subnetting.md)
4. **Include architecture diagram** (from project7-architecture.md)
5. **Document any issues** encountered and solutions
6. **Export to PDF**

---

## 📋 Quick Checklist

### Before You Start
- [ ] AWS account access verified
- [ ] IAM credentials working
- [ ] VMware Workstation installed
- [ ] Windows 10 and CentOS ISOs downloaded
- [ ] Downloaded all 3 project files
- [ ] Read through deployment guide once

### During Deployment
- [ ] Taking screenshots at each checkpoint
- [ ] Saving configuration values (VPC ID, Subnet IDs, etc.)
- [ ] Testing connectivity after each major step
- [ ] Documenting any deviations or issues

### Before Submission
- [ ] All 44+ screenshots captured and labeled
- [ ] IP subnetting table completed
- [ ] All services tested and working
- [ ] WordPress accessible via Load Balancer
- [ ] Auto Scaling tested (terminate instance, verify replacement)
- [ ] S3 website accessible
- [ ] VPC peering tested
- [ ] Final report compiled
- [ ] Reviewed for completeness

---

## 💡 Pro Tips

### AWS Console
1. **Keep multiple tabs open** - VPC, EC2, RDS dashboards
2. **Use search** - Type service names in AWS search bar
3. **Note Resource IDs** - Keep a notepad with VPC ID, Subnet IDs, etc.
4. **Take screenshots immediately** - Don't wait!

### Troubleshooting
1. **If WordPress doesn't load:**
   - Check security group allows HTTP (80)
   - Verify NGINX is running: `sudo systemctl status nginx`
   - Check PHP-FPM: `sudo systemctl status php-fpm`
   - Review NGINX logs: `sudo tail -f /var/log/nginx/error.log`

2. **If database connection fails:**
   - Verify RDS endpoint is correct
   - Check security group allows MySQL (3306)
   - Test from EC2: `mysql -h [RDS-endpoint] -u root -p`

3. **If Auto Scaling doesn't work:**
   - Check AMI status is "available"
   - Verify launch template references correct AMI
   - Check target group health checks
   - Review Auto Scaling activity history

### Cost Management
1. **Use Free Tier eligible resources** (t2.micro, db.t3.micro)
2. **Stop/terminate resources** when not actively working
3. **Delete resources** after project submission to avoid charges
4. **Set up billing alerts** in AWS

---

## 🎯 Success Criteria

Your project is complete when:

✅ Windows 10 VM running with network info documented  
✅ CentOS VM running with network info documented  
✅ VPC with 4 subnets created  
✅ 2 EC2 instances running (cloudserver + webserver)  
✅ WordPress installed and accessible  
✅ RDS MySQL database connected  
✅ S3 static website live  
✅ NAT Gateway providing internet to private subnet  
✅ EFS mounted on cloudserver  
✅ VPC peering configured  
✅ AMI created from webserver  
✅ Auto Scaling Group maintaining 2 instances  
✅ Load Balancer distributing traffic  
✅ WordPress accessible via ALB from Windows VM  
✅ All screenshots captured (44+)  
✅ Report compiled and polished  

---

## 📞 Need Help?

If you get stuck on a specific task:

1. **Check the deployment guide** - It has detailed steps for each task
2. **Review the architecture diagram** - Understand how components connect
3. **Consult AWS documentation** - Links provided in deployment guide
4. **Ask me!** - I'm here to help clarify or troubleshoot

---

## 🔄 Next Steps

**Right Now:**
1. Download all 3 files
2. Read project7-aws-deployment-guide.md completely
3. Set up your AWS environment
4. Start with Parts 1 & 2 (VMs)

**Then:**
1. Follow deployment guide for Part 3 (AWS Resources)
2. Take screenshots at every checkpoint
3. Test each component as you build it

**Finally:**
1. Complete Part 4 (High Availability)
2. Compile all screenshots into report
3. Add IP subnetting table and architecture diagram
4. Submit!

---

**You have everything you need to succeed!** The deployment guide is extremely detailed - just follow it step by step and you'll build a production-grade AWS infrastructure! 🚀

**Estimated completion:** 11-15 hours of focused work

**Good luck!** 🎉
