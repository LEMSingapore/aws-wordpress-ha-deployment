#!/bin/bash

# Script to create AMI from webserver and deploy Auto Scaling Group

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "========================================"
echo " Create AMI & Deploy Auto Scaling"
echo "========================================"
echo -e "${NC}"

# Get instance ID
INSTANCE_ID=$(terraform output -raw webserver_instance_id)
echo -e "${YELLOW}Webserver Instance ID:${NC} $INSTANCE_ID"

# Check if WordPress is configured
echo ""
echo -e "${YELLOW}⚠ Make sure WordPress is fully configured before creating AMI!${NC}"
echo ""
read -p "Have you configured and tested WordPress? (yes/no): " confirmed

if [ "$confirmed" != "yes" ]; then
    echo -e "${RED}Please configure WordPress first, then run this script again.${NC}"
    exit 0
fi

# Stop instance
echo ""
echo -e "${YELLOW}Step 1: Stopping webserver instance...${NC}"
aws ec2 stop-instances --instance-ids $INSTANCE_ID

echo "Waiting for instance to stop..."
aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID
echo -e "${GREEN}✓ Instance stopped${NC}"

# Create AMI
echo ""
echo -e "${YELLOW}Step 2: Creating AMI (this takes 5-10 minutes)...${NC}"
AMI_ID=$(aws ec2 create-image \
    --instance-id $INSTANCE_ID \
    --name "img-cheeyoung" \
    --description "WordPress webserver image for Auto Scaling" \
    --query 'ImageId' \
    --output text)

echo -e "${GREEN}✓ AMI creation initiated${NC}"
echo -e "${YELLOW}AMI ID:${NC} $AMI_ID"

echo "Waiting for AMI to be available..."
aws ec2 wait image-available --image-ids $AMI_ID
echo -e "${GREEN}✓ AMI is ready!${NC}"

# Add AMI ID to terraform.tfvars
echo ""
echo -e "${YELLOW}Step 3: Updating terraform configuration...${NC}"

# Check if webserver_ami_id already exists in terraform.tfvars
if grep -q "webserver_ami_id" terraform.tfvars; then
    # Update existing line
    sed -i.bak "s|webserver_ami_id = .*|webserver_ami_id = \"$AMI_ID\"|g" terraform.tfvars
    rm terraform.tfvars.bak
else
    # Add new line
    echo "" >> terraform.tfvars
    echo "# AMI created from webserver (added by create-ami-and-asg.sh)" >> terraform.tfvars
    echo "webserver_ami_id = \"$AMI_ID\"" >> terraform.tfvars
fi

echo -e "${GREEN}✓ terraform.tfvars updated${NC}"

# Update asg.tf to uncomment the Auto Scaling configuration
echo ""
echo -e "${YELLOW}Step 4: Enabling Auto Scaling Group in Terraform...${NC}"

# Remove the comment blocks from asg.tf
sed -i.bak 's|^/\*||g; s|\*/||g' asg.tf
rm asg.tf.bak

echo -e "${GREEN}✓ Auto Scaling configuration enabled${NC}"

# Apply Terraform changes
echo ""
echo -e "${YELLOW}Step 5: Deploying Auto Scaling Group...${NC}"
terraform plan -out=tfplan-asg
terraform apply tfplan-asg

# Display results
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} Auto Scaling Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

ALB_DNS=$(terraform output -raw alb_dns_name)

echo -e "${BLUE}Load Balancer URL:${NC}"
echo "http://$ALB_DNS"
echo "http://$ALB_DNS/wordpress"
echo ""

echo -e "${BLUE}Auto Scaling Group:${NC}"
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names as-group-cheeyoung \
    --query 'AutoScalingGroups[0].[AutoScalingGroupName,DesiredCapacity,MinSize,MaxSize]' \
    --output table

echo ""
echo -e "${BLUE}Instances in Target Group:${NC}"
aws elbv2 describe-target-health \
    --target-group-arn $(aws elbv2 describe-target-groups \
        --names cluster-cheeyoung \
        --query 'TargetGroups[0].TargetGroupArn' \
        --output text) \
    --query 'TargetHealthDescriptions[*].[Target.Id,TargetHealth.State]' \
    --output table

echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Test Load Balancer: http://$ALB_DNS/wordpress"
echo "2. Test from Windows 10 VM (Part 1)"
echo "3. Verify Auto Scaling by terminating an instance"
echo "4. Take screenshots for Part 4"
echo ""
echo -e "${YELLOW}📸 Screenshot checklist:${NC}"
echo "  - AMI created (AWS Console)"
echo "  - Launch Template"
echo "  - Auto Scaling Group configuration"
echo "  - Auto Scaling Group instances"
echo "  - Load Balancer DNS"
echo "  - Target Group health checks"
echo "  - WordPress accessible via Load Balancer"
echo "  - Scaling policy configured"
echo ""
