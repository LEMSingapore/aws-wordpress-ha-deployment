# Project 7 - IP Subnetting Solution

## Requirements

Using VPC: **10.X.0.0/16** (where X = your group number)

For example, if X = 1, then VPC CIDR is **10.1.0.0/16**

### Host Requirements (already includes AWS reserved addresses)

| Subnet | Hosts Needed |
|--------|-------------|
| Subnet 1 | 70 hosts |
| Subnet 2 | 30 hosts |
| Subnet 3 | 10 hosts |
| Subnet 4 | 10 hosts |

---

## Solution Using VLSM (Variable Length Subnet Masking)

### Step 1: Determine Subnet Masks

For each subnet, we need to find the smallest subnet that can accommodate the required hosts.

**Formula:** 2^n - 2 ≥ required hosts (where n = host bits)

- **Subnet 1 (70 hosts):** Need 2^7 - 2 = 126 usable IPs → /25 (255.255.255.128)
- **Subnet 2 (30 hosts):** Need 2^5 - 2 = 30 usable IPs → /27 (255.255.255.224)
- **Subnet 3 (10 hosts):** Need 2^4 - 2 = 14 usable IPs → /28 (255.255.255.240)
- **Subnet 4 (10 hosts):** Need 2^4 - 2 = 14 usable IPs → /28 (255.255.255.240)

---

## Complete IP Subnetting Table

**Assuming VPC CIDR: 10.1.0.0/16** (replace 10.1 with 10.X where X is your group number)

| Subnet | Subnet Mask | CIDR | Network Address | First Usable | Last Usable | Broadcast Address | Usable IPs |
|--------|-------------|------|----------------|--------------|-------------|-------------------|------------|
| **Subnet 1** | 255.255.255.128 | /25 | 10.1.0.0 | 10.1.0.1 | 10.1.0.126 | 10.1.0.127 | 126 |
| **Subnet 2** | 255.255.255.224 | /27 | 10.1.0.128 | 10.1.0.129 | 10.1.0.158 | 10.1.0.159 | 30 |
| **Subnet 3** | 255.255.255.240 | /28 | 10.1.0.160 | 10.1.0.161 | 10.1.0.174 | 10.1.0.175 | 14 |
| **Subnet 4** | 255.255.255.240 | /28 | 10.1.0.176 | 10.1.0.177 | 10.1.0.190 | 10.1.0.191 | 14 |

---

## Subnet Usage

- **Subnet 1 (10.1.0.0/25)** - Public subnet for web servers (70 hosts)
- **Subnet 2 (10.1.0.128/27)** - Public subnet for future expansion (30 hosts)
- **Subnet 3 (10.1.0.160/28)** - Public subnet for management (10 hosts)
- **Subnet 4 (10.1.0.176/28)** - **Private subnet** for cloud server (10 hosts)

---

## High Availability Considerations

For HA design, you should create these subnets across **different Availability Zones**:

### Recommended AZ Placement

| Subnet | Availability Zone | Purpose |
|--------|------------------|---------|
| Subnet 1 | ap-southeast-1a | Public - Web servers (Primary) |
| Subnet 2 | ap-southeast-1b | Public - Web servers (Secondary) |
| Subnet 3 | ap-southeast-1c | Public - Management/Bastion |
| Subnet 4 | ap-southeast-1a | Private - Cloud server & Database |

**Note:** RDS will automatically create its own subnets in multiple AZs when you choose "Automatic setup"

---

## AWS VPC Configuration Commands

### Using AWS CLI

```bash
# Create VPC
aws ec2 create-vpc \
  --cidr-block 10.1.0.0/16 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=vpc-capstone1}]'

# Create Subnet 1 (Public - Web Servers)
aws ec2 create-subnet \
  --vpc-id vpc-xxxxx \
  --cidr-block 10.1.0.0/25 \
  --availability-zone ap-southeast-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subnet-1}]'

# Create Subnet 2 (Public - HA Web Servers)
aws ec2 create-subnet \
  --vpc-id vpc-xxxxx \
  --cidr-block 10.1.0.128/27 \
  --availability-zone ap-southeast-1b \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subnet-2}]'

# Create Subnet 3 (Public - Management)
aws ec2 create-subnet \
  --vpc-id vpc-xxxxx \
  --cidr-block 10.1.0.160/28 \
  --availability-zone ap-southeast-1c \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subnet-3}]'

# Create Subnet 4 (Private - Cloud Server)
aws ec2 create-subnet \
  --vpc-id vpc-xxxxx \
  --cidr-block 10.1.0.176/28 \
  --availability-zone ap-southeast-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subnet-4}]'
```

---

## Verification Checklist

✅ Subnet 1: 70+ usable IPs (requirement: 70) - **126 available**  
✅ Subnet 2: 30+ usable IPs (requirement: 30) - **30 available**  
✅ Subnet 3: 10+ usable IPs (requirement: 10) - **14 available**  
✅ Subnet 4: 10+ usable IPs (requirement: 10) - **14 available**  
✅ No overlapping IP ranges  
✅ Efficient use of IP space (VLSM)  
✅ Room for future expansion  

---

## Important Notes

1. **AWS Reserved IPs:** AWS reserves 5 IPs in each subnet:
   - First IP: Network address
   - Second IP: VPC router
   - Third IP: DNS server
   - Fourth IP: Future use
   - Last IP: Broadcast address

2. **Replace 10.1 with your actual VPC prefix** (10.X where X is your group number)

3. **Subnet 4 is PRIVATE:** It should NOT have a route to Internet Gateway

4. **High Availability:** Distribute subnets across multiple AZs as shown above

---

**This solution meets all requirements and follows AWS best practices!**
