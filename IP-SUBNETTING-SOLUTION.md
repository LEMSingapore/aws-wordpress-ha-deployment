# Project 7: IP Subnetting Solution (VLSM)

**Student**: Chee Young Chang
**Base Network**: 10.1.0.0/16
**Method**: Variable Length Subnet Masking (VLSM)

---

## Requirements

| Subnet | Required Hosts |
|--------|----------------|
| Subnet 1 | 70 hosts |
| Subnet 2 | 30 hosts |
| Subnet 3 | 10 hosts |
| Subnet 4 | 10 hosts |

---

## VLSM Calculation Process

### Step 1: Sort by Host Requirements (Largest to Smallest)
1. Subnet 1: 70 hosts
2. Subnet 2: 30 hosts
3. Subnet 3: 10 hosts
4. Subnet 4: 10 hosts

### Step 2: Calculate Required Bits for Each Subnet

**Formula**: 2^n - 2 ≥ required hosts (where n = host bits)

**Subnet 1 (70 hosts)**:
- 2^6 - 2 = 62 hosts ❌ (not enough)
- 2^7 - 2 = 126 hosts ✅
- Host bits needed: 7
- Network bits: 32 - 7 = 25
- **Subnet mask: /25**

**Subnet 2 (30 hosts)**:
- 2^4 - 2 = 14 hosts ❌
- 2^5 - 2 = 30 hosts ✅
- Host bits needed: 5
- Network bits: 32 - 5 = 27
- **Subnet mask: /27**

**Subnet 3 (10 hosts)**:
- 2^3 - 2 = 6 hosts ❌
- 2^4 - 2 = 14 hosts ✅
- Host bits needed: 4
- Network bits: 32 - 4 = 28
- **Subnet mask: /28**

**Subnet 4 (10 hosts)**:
- Same as Subnet 3
- **Subnet mask: /28**

### Step 3: Allocate Subnet Addresses

Starting from base network: **10.1.0.0/16**

**Subnet 1** (largest first):
- Prefix length: /25
- Block size: 2^7 = 128 addresses
- Network: **10.1.0.0/25**
- Range: 10.1.0.0 - 10.1.0.127

**Subnet 2**:
- Prefix length: /27
- Block size: 2^5 = 32 addresses
- Start after Subnet 1: 10.1.0.128
- Network: **10.1.0.128/27**
- Range: 10.1.0.128 - 10.1.0.159

**Subnet 3**:
- Prefix length: /28
- Block size: 2^4 = 16 addresses
- Start after Subnet 2: 10.1.0.160
- Network: **10.1.0.160/28**
- Range: 10.1.0.160 - 10.1.0.175

**Subnet 4**:
- Prefix length: /28
- Block size: 2^4 = 16 addresses
- Start after Subnet 3: 10.1.0.176
- Network: **10.1.0.176/28**
- Range: 10.1.0.176 - 10.1.0.191

---

## Final IP Subnetting Table

| Subnet | Network Address | Subnet Mask | First Usable IP | Last Usable IP | Broadcast Address | Usable Hosts | Requirement Met |
|--------|----------------|-------------|-----------------|----------------|-------------------|--------------|-----------------|
| **Subnet 1** | 10.1.0.0 | 255.255.255.128 (/25) | 10.1.0.1 | 10.1.0.126 | 10.1.0.127 | 126 | ✅ 70 hosts |
| **Subnet 2** | 10.1.0.128 | 255.255.255.224 (/27) | 10.1.0.129 | 10.1.0.158 | 10.1.0.159 | 30 | ✅ 30 hosts |
| **Subnet 3** | 10.1.0.160 | 255.255.255.240 (/28) | 10.1.0.161 | 10.1.0.174 | 10.1.0.175 | 14 | ✅ 10 hosts |
| **Subnet 4** | 10.1.0.176 | 255.255.255.240 (/28) | 10.1.0.177 | 10.1.0.190 | 10.1.0.191 | 14 | ✅ 10 hosts |

---

## Detailed Breakdown

### Subnet 1: 10.1.0.0/25

**Binary Representation**:
```
Network:   10.1.0.00000000  (10.1.0.0)
First IP:  10.1.0.00000001  (10.1.0.1)
Last IP:   10.1.0.01111110  (10.1.0.126)
Broadcast: 10.1.0.01111111  (10.1.0.127)
Mask:      11111111.11111111.11111111.10000000  (255.255.255.128)
```

**Usage**: Public subnet for EC2 webservers (primary AZ)

---

### Subnet 2: 10.1.0.128/27

**Binary Representation**:
```
Network:   10.1.0.10000000  (10.1.0.128)
First IP:  10.1.0.10000001  (10.1.0.129)
Last IP:   10.1.0.10011110  (10.1.0.158)
Broadcast: 10.1.0.10011111  (10.1.0.159)
Mask:      11111111.11111111.11111111.11100000  (255.255.255.224)
```

**Usage**: Public subnet for multi-AZ deployment (second AZ)

---

### Subnet 3: 10.1.0.160/28

**Binary Representation**:
```
Network:   10.1.0.10100000  (10.1.0.160)
First IP:  10.1.0.10100001  (10.1.0.161)
Last IP:   10.1.0.10101110  (10.1.0.174)
Broadcast: 10.1.0.10101111  (10.1.0.175)
Mask:      11111111.11111111.11111111.11110000  (255.255.255.240)
```

**Usage**: Public subnet for multi-AZ deployment (third AZ)

---

### Subnet 4: 10.1.0.176/28

**Binary Representation**:
```
Network:   10.1.0.10110000  (10.1.0.176)
First IP:  10.1.0.10110001  (10.1.0.177)
Last IP:   10.1.0.10111110  (10.1.0.190)
Broadcast: 10.1.0.10111111  (10.1.0.191)
Mask:      11111111.11111111.11111111.11110000  (255.255.255.240)
```

**Usage**: Private subnet for cloudserver (no direct internet access)

---

## AWS Subnet Configuration

### Subnet 1 (Public)
```hcl
cidr_block              = "10.1.0.0/25"
availability_zone       = "ap-southeast-1a"
map_public_ip_on_launch = true
route_table             = public (via Internet Gateway)
```

**Resources**:
- webserver-cheeyoung (initial)
- Auto Scaling Group instances
- Application Load Balancer

### Subnet 2 (Public)
```hcl
cidr_block              = "10.1.0.128/27"
availability_zone       = "ap-southeast-1b"
map_public_ip_on_launch = true
route_table             = public (via Internet Gateway)
```

**Resources**:
- Auto Scaling Group instances (multi-AZ)
- RDS database (multi-AZ standby)

### Subnet 3 (Public)
```hcl
cidr_block              = "10.1.0.160/28"
availability_zone       = "ap-southeast-1c"
map_public_ip_on_launch = true
route_table             = public (via Internet Gateway)
```

**Resources**:
- Auto Scaling Group instances (multi-AZ)
- Application Load Balancer nodes

### Subnet 4 (Private)
```hcl
cidr_block              = "10.1.0.176/28"
availability_zone       = "ap-southeast-1a"
map_public_ip_on_launch = false
route_table             = private (via NAT Gateway)
```

**Resources**:
- cloudserver-cheeyoung
- EFS mount target

---

## Verification Commands

### AWS CLI

```bash
# List all subnets
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-xxxxx" \
  --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone,Tags[?Key==`Name`].Value|[0]]' \
  --output table

# Verify CIDR blocks
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-xxxxx" \
  --query 'Subnets[*].[CidrBlock]' \
  --output text
```

### Terraform

```bash
# Show subnet information
terraform output subnet_cidrs

# Verify all subnets created
terraform state list | grep aws_subnet
```

### Network Calculator Verification

You can verify these calculations using online tools:
- https://www.subnet-calculator.com/
- https://www.calculator.net/ip-subnet-calculator.html

Input: 10.1.0.0/25, 10.1.0.128/27, 10.1.0.160/28, 10.1.0.176/28

---

## Why VLSM?

**Variable Length Subnet Masking (VLSM)** is used because:

1. **Efficient IP Address Utilization**: Each subnet gets exactly the space it needs
   - Subnet 1 needs 70 hosts → gets /25 (126 usable)
   - Subnet 2 needs 30 hosts → gets /27 (30 usable)
   - Subnets 3 & 4 need 10 hosts → get /28 (14 usable each)

2. **No IP Waste**: Traditional subnetting would give all subnets the same size
   - Without VLSM: All 4 subnets would be /25 = 512 IPs (384 wasted!)
   - With VLSM: Only 184 IPs used (very efficient)

3. **Scalability**: Remaining space in 10.1.0.0/16 available for future subnets
   - Used: 10.1.0.0 - 10.1.0.191 (192 addresses)
   - Available: 10.1.0.192 - 10.1.255.255 (65,344 addresses for future growth!)

---

## Common Questions

### Q: Why does Subnet 1 come before Subnet 2 in the address space?
**A**: VLSM allocation starts with the largest subnet first to prevent fragmentation. This ensures efficient address utilization.

### Q: Can I use different subnet masks?
**A**: Yes, but you'd waste IPs or not meet requirements:
- Using /26 for Subnet 1: 62 usable (not enough for 70!)
- Using /24 for all: Wastes many IPs

### Q: What happens if I add more resources?
**A**: You have plenty of space! The entire 10.1.0.0/16 network has 65,536 addresses, and you've only used 192 (0.3%).

### Q: Why is Subnet 4 private while others are public?
**A**: Design decision for security:
- **Public subnets** (1, 2, 3): Need internet access for webservers and load balancer
- **Private subnet** (4): Cloudserver doesn't need direct internet access; uses NAT Gateway

---

## Summary

✅ All 4 subnets fit within 10.1.0.0/16 VPC
✅ Each subnet meets or exceeds host requirements
✅ No overlapping IP ranges
✅ Efficient IP address utilization with VLSM
✅ Room for future expansion
✅ Proper segregation between public and private subnets

**Total addresses used**: 192 out of 65,536 (0.3%)
**Addresses available for future**: 65,344 (99.7%)

This is production-ready IP planning! 🎉
