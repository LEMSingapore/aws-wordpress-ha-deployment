#!/bin/bash

# Project 7: AWS High Availability WordPress Deployment Script
# Student: Chee Young Chang

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "========================================"
echo " Project 7: AWS HA WordPress Deployment"
echo " Terraform Automation"
echo "========================================"
echo -e "${NC}"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}✗ AWS CLI not installed${NC}"
    echo "Install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi
echo -e "${GREEN}✓ AWS CLI installed${NC}"

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}✗ Terraform not installed${NC}"
    echo "Install: brew install terraform  OR  https://www.terraform.io/downloads"
    exit 1
fi
echo -e "${GREEN}✓ Terraform installed${NC}"

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}✗ AWS credentials not configured${NC}"
    echo "Run: aws configure"
    exit 1
fi
echo -e "${GREEN}✓ AWS credentials configured${NC}"

# Check terraform.tfvars
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}⚠ terraform.tfvars not found${NC}"
    echo ""
    echo "Please create terraform.tfvars from the example:"
    echo "  cp terraform.tfvars.example terraform.tfvars"
    echo ""
    echo "Then edit it with your values:"
    echo "  - my_ip: Your public IP (get from https://checkip.amazonaws.com)"
    echo "  - db_password: Strong password for RDS"
    echo ""
    read -p "Do you want me to help you create it now? (y/n): " create_tfvars

    if [ "$create_tfvars" == "y" ]; then
        cp terraform.tfvars.example terraform.tfvars

        # Get user's public IP
        MY_IP=$(curl -s https://checkip.amazonaws.com)
        echo ""
        echo -e "${GREEN}Your public IP: $MY_IP${NC}"

        # Ask for database password
        echo ""
        read -sp "Enter RDS database password: " db_password
        echo ""
        read -sp "Confirm password: " db_password_confirm
        echo ""

        if [ "$db_password" != "$db_password_confirm" ]; then
            echo -e "${RED}Passwords don't match!${NC}"
            exit 1
        fi

        # Update terraform.tfvars
        sed -i.bak "s|YOUR_PUBLIC_IP/32|$MY_IP/32|g" terraform.tfvars
        sed -i.bak "s|YourStrongPassword123!|$db_password|g" terraform.tfvars
        rm terraform.tfvars.bak

        echo -e "${GREEN}✓ terraform.tfvars created${NC}"
    else
        exit 1
    fi
fi

# Check/create SSH key pair
KEY_NAME="keypair-cheeyoung"
if [ ! -f "${KEY_NAME}.pem" ]; then
    echo -e "${YELLOW}SSH key pair not found. Creating...${NC}"
    aws ec2 create-key-pair \
        --key-name $KEY_NAME \
        --query 'KeyMaterial' \
        --output text > ${KEY_NAME}.pem
    chmod 400 ${KEY_NAME}.pem
    echo -e "${GREEN}✓ SSH key pair created: ${KEY_NAME}.pem${NC}"
else
    echo -e "${GREEN}✓ SSH key pair exists${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE} Phase 1: Infrastructure Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Initialize Terraform
echo -e "${YELLOW}Step 1: Initializing Terraform...${NC}"
terraform init

# Validate configuration
echo ""
echo -e "${YELLOW}Step 2: Validating configuration...${NC}"
terraform validate

# Plan deployment
echo ""
echo -e "${YELLOW}Step 3: Planning deployment...${NC}"
terraform plan -out=tfplan

# Ask for confirmation
echo ""
echo -e "${YELLOW}This will create:${NC}"
echo "  - VPC with 4 subnets (VLSM)"
echo "  - Internet Gateway + NAT Gateway"
echo "  - 2 EC2 instances (webserver + cloudserver)"
echo "  - RDS MySQL database"
echo "  - S3 static website"
echo "  - EFS file system"
echo "  - Application Load Balancer"
echo ""
echo -e "${YELLOW}Estimated cost: ~$0.50/hour (~$12/day)${NC}"
echo ""
read -p "Proceed with deployment? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${RED}Deployment cancelled${NC}"
    exit 0
fi

# Apply configuration
echo ""
echo -e "${YELLOW}Step 4: Deploying infrastructure (this takes 5-10 minutes)...${NC}"
terraform apply tfplan

# Save outputs
terraform output > deployment-info.txt
echo -e "${GREEN}✓ Outputs saved to deployment-info.txt${NC}"

# Display important information
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} Phase 1 Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

WEBSERVER_IP=$(terraform output -raw webserver_public_ip)
RDS_ENDPOINT=$(terraform output -raw rds_address)
S3_WEBSITE=$(terraform output -raw s3_website_endpoint)
ALB_URL=$(terraform output -raw alb_dns_name)

echo -e "${BLUE}Important Information:${NC}"
echo ""
echo -e "${YELLOW}Webserver Public IP:${NC} $WEBSERVER_IP"
echo -e "${YELLOW}RDS Endpoint:${NC} $RDS_ENDPOINT"
echo -e "${YELLOW}S3 Website:${NC} $S3_WEBSITE"
echo -e "${YELLOW}Load Balancer:${NC} http://$ALB_URL"
echo ""

echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "1. Configure WordPress:"
echo "   ssh -i ${KEY_NAME}.pem ec2-user@$WEBSERVER_IP"
echo "   cd /usr/share/nginx/html/wordpress"
echo "   sudo cp wp-config-sample.php wp-config.php"
echo "   sudo nano wp-config.php"
echo "   # Update DB_HOST to: $RDS_ENDPOINT"
echo ""
echo "2. Install WordPress:"
echo "   Open in browser: http://$WEBSERVER_IP/wordpress"
echo ""
echo "3. Create AMI and deploy Auto Scaling:"
echo "   ./create-ami-and-asg.sh"
echo ""
echo -e "${YELLOW}📸 Don't forget to take screenshots!${NC}"
echo ""
