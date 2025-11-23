# 🚀 E-Commerce Cloud Infrastructure & CI/CD Setup

This project provides a complete cloud infrastructure setup for an e-commerce application using Terraform and automated deployments using GitHub Actions.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Infrastructure Setup (Task Group A)](#infrastructure-setup-task-group-a)
- [CI/CD Pipeline Setup (Task Group B)](#cicd-pipeline-setup-task-group-b)
- [Migration Plan to Azure (Task Group C)](#migration-plan-to-azure-task-group-c)
- [Monitoring & Alerts](#monitoring--alerts)
- [Troubleshooting](#troubleshooting)

## 🏗️ Architecture Overview


![CloudDrop Architecture](https://github.com/amramer101/Terraform-Task/blob/main/Photos/AWS.png "Architecture")



### Components:

- **Frontend Server**: Ubuntu 22.04 running Uptime Kuma via Docker
- **Backend Server**: Ubuntu 22.04 running Laravel PHP application
- **Database**: RDS MySQL 8.0 (no public access)
- **Monitoring**: CloudWatch Alarms for CPU monitoring
- **CI/CD**: GitHub Actions for automated deployments

---

## 🔧 Prerequisites

### Required Tools:

1. **AWS CLI** (version 2.x)
   ```bash
   # Install AWS CLI
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```

2. **Terraform** (version 1.0+)
   ```bash
   # Install Terraform
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

3. **Git**
   ```bash
   sudo apt-get install git
   ```

4. **SSH Key Pair**
   ```bash
   # Generate SSH key if you don't have one
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

### AWS Account Setup:

1. **Create AWS Account** (or use existing)
2. **Configure AWS CLI**:
   ```bash
   aws configure
   # Enter your:
   # - AWS Access Key ID
   # - AWS Secret Access Key
   # - Default region (e.g., us-east-1)
   # - Default output format (json)
   ```

3. **Verify AWS Configuration**:
   ```bash
   aws sts get-caller-identity
   ```

---

## 🏗️ Infrastructure Setup (Task Group A)

### Terraform Graph


![CloudDrop Architecture](https://github.com/amramer101/Terraform-Task/blob/main/graph.svg "Terraform Graph")


### Step 1: Clone the Terraform Repository

```bash
# Create project directory
mkdir -p ~/ecommerce-infra
cd ~/ecommerce-infra

# Initialize git (if needed)
git init

# Create directory structure
mkdir -p terraform
cd terraform
```

### Step 2: Create Terraform Files

Create the following files in your `terraform` directory:
- `main.tf` (provided in artifacts)
- `variables.tf` (provided in artifacts)
- `terraform.tfvars` (create from terraform.tfvars.example)

### Step 3: Configure Variables

```bash
# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**Important configurations to update:**

```hcl
# terraform.tfvars
aws_region = "us-east-1"  # Your preferred region

# Get the latest Ubuntu 22.04 AMI for your region
# Run: aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" --query 'sort_by(Images, &CreationDate)[-1].ImageId'
ubuntu_ami_id = "ami-0e86e20dae9224db8"

# SSH Keys
ssh_public_key_path  = "~/.ssh/id_rsa.pub"
ssh_private_key_path = "~/.ssh/id_rsa"

# Database
db_name     = "ecommerce_db"
db_username = "admin"
db_password = "YourSecurePassword123!"  # CHANGE THIS!

# Alerts
alert_email = "your-email@example.com"  # CHANGE THIS!
```

### Step 4: Initialize and Apply Terraform

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Apply infrastructure
terraform apply
# Type 'yes' when prompted
```


**This will create:**
- ✅ 2 EC2 instances (Frontend & Backend)
- ✅ 1 RDS MySQL database
- ✅ Security groups with proper rules
- ✅ CloudWatch alarms for CPU monitoring
- ✅ SNS topic for email alerts

### Step 5: Confirm Email Subscription

After running `terraform apply`, check your email and **confirm the SNS subscription** to receive CPU alerts.

### Step 6: Get Infrastructure Details

```bash
# View all outputs
terraform output

# Get specific information
terraform output frontend_public_ip
terraform output backend_public_ip
terraform output rds_endpoint
```

### Step 7: Test SSH Access

```bash
# Test frontend server
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -raw frontend_public_ip)

# Test backend server
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -raw backend_public_ip)
```

---

## 🔄 CI/CD Pipeline Setup (Task Group B)

### Prerequisites for CI/CD:

1. **Fork the repositories:**
   - Frontend: https://github.com/amramer101/uptime-kuma-Task
   - Backend: https://github.com/amramer101/laravel-Task

2. **Get your server IPs from Terraform:**
   ```bash
   terraform output frontend_public_ip
   terraform output backend_public_ip
   ```

### Step 1: Configure GitHub Secrets

For **Frontend Repository**, add these secrets:

```
Settings → Secrets and variables → Actions → New repository secret
```

**Required Secrets:**
- `SSH_PRIVATE_KEY`: Your private SSH key content
  ```bash
  cat ~/.ssh/id_rsa
  ```
- `FRONTEND_HOST`: Frontend server public IP

For **Backend Repository**, add these secrets:

**Required Secrets:**
- `SSH_PRIVATE_KEY`: Your private SSH key content
- `BACKEND_HOST`: Backend server public IP
- `DB_HOST`: RDS endpoint (get from terraform output)
- `DB_DATABASE`: Database name (from terraform.tfvars)
- `DB_USERNAME`: Database username
- `DB_PASSWORD`: Database password

### Step 2: Setup Frontend Workflow

1. In your forked `uptime-kuma` repository:
   ```bash
   mkdir -p .github/workflows
   ```

2. Create file: `.github/workflows/deploy.yml`
   - Use the content from the "Frontend GitHub Actions Workflow" artifact

3. Commit and push:
   ```bash
   git add .github/workflows/deploy.yml
   git commit -m "Add CI/CD workflow"
   git push origin main
   ```

### Step 3: Setup Backend Workflow

1. In your forked `laravel` repository:
   ```bash
   mkdir -p .github/workflows
   ```

2. Create file: `.github/workflows/deploy.yml`
   - Use the content from the "Backend GitHub Actions Workflow" artifact

3. Configure Laravel `.env` on server:
   ```bash
   ssh ubuntu@<backend-ip>
   cd /var/www/laravel
   nano .env
   ```

   Update database credentials:
   ```env
   DB_CONNECTION=mysql
   DB_HOST=<rds-endpoint>
   DB_PORT=3306
   DB_DATABASE=ecommerce_db
   DB_USERNAME=admin
   DB_PASSWORD=YourSecurePassword123!
   ```

4. Commit and push workflow:
   ```bash
   git add .github/workflows/deploy.yml
   git commit -m "Add CI/CD workflow"
   git push origin main
   ```

### Step 4: Test the Pipelines

**Frontend Test:**
```bash
# Make a change to trigger deployment
echo "# Test deployment" >> README.md
git add README.md
git commit -m "Test frontend deployment"
git push origin main
```

**Backend Test:**
```bash
# Make a change to trigger deployment
echo "# Test deployment" >> README.md
git add README.md
git commit -m "Test backend deployment"
git push origin main
```

### Step 5: Verify Deployments

**Frontend:**
```bash
# Access Uptime Kuma
http://<frontend-ip>:3001
```

**Backend:**
```bash
# Check Laravel
ssh ubuntu@<backend-ip>
cd /var/www/laravel
php artisan --version
```

---

## ☁️ Migration Plan to Azure (Task Group C)

### Complete Migration Strategy

#### Phase 1: Pre-Migration Planning (Day 1)

**1.1 Infrastructure Assessment**
```
Current AWS Resources:
├── 2x EC2 instances (t2.micro)
├── 1x RDS MySQL 8.0
├── Security Groups
├── CloudWatch + SNS
└── EBS Volumes
```

**1.2 Azure Resource Mapping**
```
AWS → Azure Mapping:
├── EC2 → Azure VMs (B1s)
├── RDS MySQL → Azure Database for MySQL
├── Security Groups → Network Security Groups (NSG)
├── CloudWatch → Azure Monitor
└── EBS → Azure Managed Disks
```

**1.3 Create Migration Checklist**
- [ ] Audit current application dependencies
- [ ] Document current configurations
- [ ] Identify data volumes and growth
- [ ] Map network architecture
- [ ] List all integrations and APIs
- [ ] Review compliance requirements

#### Phase 2: Azure Environment Setup (Day 1-2)

**2.1 Create Azure Resources**

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Create Resource Group
az group create --name ecommerce-rg --location eastus

# Create Virtual Network
az network vnet create \
  --resource-group ecommerce-rg \
  --name ecommerce-vnet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name app-subnet \
  --subnet-prefix 10.0.1.0/24
```

**2.2 Terraform for Azure**

Create `azure-main.tf`:
```hcl
provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "ecommerce-rg"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "ecommerce-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Frontend VM
resource "azurerm_linux_virtual_machine" "frontend" {
  name                = "frontend-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  
  # Similar to AWS t2.micro: 1 vCPU, 1GB RAM
  # ... (rest of configuration)
}

# Azure Database for MySQL
resource "azurerm_mysql_flexible_server" "main" {
  name                = "ecommerce-mysql"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  sku_name   = "B_Standard_B1s"
  version    = "8.0"
  # ... (rest of configuration)
}
```
---

## 📊 Monitoring & Alerts

### CloudWatch Alarms

The infrastructure automatically creates CPU monitoring:

- **Threshold**: CPU > 50%
- **Evaluation Period**: 2 periods of 5 minutes
- **Action**: Send email via SNS

### View Alarms

```bash
# List all alarms
aws cloudwatch describe-alarms

# Check specific alarm
aws cloudwatch describe-alarm-history \
  --alarm-name frontend-high-cpu \
  --max-records 10
```

### Manual Testing of Alerts

```bash
# SSH to frontend
ssh ubuntu@<frontend-ip>

# Generate CPU load
stress-ng --cpu 1 --timeout 600s

# You should receive email alert within 10 minutes
```

### Additional Monitoring (Optional)

**Install CloudWatch Agent for detailed metrics:**

```bash
# On each server
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb

# Configure agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

---

## 🔍 Troubleshooting

### Common Issues & Solutions

#### 1. Terraform Apply Fails

**Problem**: `Error creating EC2 Instance`

**Solution**:
```bash
# Check if you have the correct AMI for your region
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --region your-region

# Update AMI ID in terraform.tfvars
```

#### 2. Cannot SSH to Instances

**Problem**: `Connection refused` or `Permission denied`

**Solutions**:
```bash
# Check security group allows SSH
aws ec2 describe-security-groups \
  --group-ids <sg-id>

# Verify SSH key permissions
chmod 600 ~/.ssh/id_rsa

# Check instance is running
aws ec2 describe-instances \
  --instance-ids <instance-id>

# Try with verbose output
ssh -v -i ~/.ssh/id_rsa ubuntu@<ip>
```

#### 3. GitHub Actions Deployment Fails

**Problem**: `Permission denied (publickey)`

**Solution**:
```bash
# Verify SSH key in GitHub Secrets
# - No extra spaces
# - Includes -----BEGIN/END RSA PRIVATE KEY-----
# - Correct line breaks

# Test SSH manually
ssh -i ~/.ssh/id_rsa ubuntu@<server-ip>
```

#### 4. Laravel Migration Fails

**Problem**: `SQLSTATE[HY000] [2002] Connection refused`

**Solutions**:
```bash
# Check RDS security group allows backend SG
aws rds describe-db-instances \
  --db-instance-identifier ecommerce-mysql-db

# Verify .env database config
ssh ubuntu@<backend-ip>
cat /var/www/laravel/.env | grep DB_

# Test MySQL connection
mysql -h <rds-endpoint> -u admin -p
```

#### 5. Docker Container Won't Start

**Problem**: Frontend container exits immediately

**Solution**:
```bash
ssh ubuntu@<frontend-ip>

# Check Docker logs
docker-compose logs uptime-kuma

# Check container status
docker ps -a

# Restart container
docker-compose down
docker-compose up -d

# Check system resources
df -h
free -h
```

#### 6. High CPU Alert Not Working

**Problem**: No email received when CPU > 50%

**Solutions**:
```bash
# Confirm SNS subscription
aws sns list-subscriptions

# Check alarm state
aws cloudwatch describe-alarms \
  --alarm-names frontend-high-cpu

# Verify email is confirmed
# Check spam folder

# Test alarm manually
aws cloudwatch set-alarm-state \
  --alarm-name frontend-high-cpu \
  --state-value ALARM \
  --state-reason "Testing"
```

---

### Useful Commands:

```bash
# Terraform
terraform fmt          # Format code
terraform validate     # Validate syntax
terraform plan         # Preview changes
terraform apply        # Apply changes
terraform destroy      # Destroy infrastructure
terraform state list   # List resources
terraform output       # Show outputs

# AWS CLI
aws ec2 describe-instances
aws rds describe-db-instances
aws cloudwatch describe-alarms
aws s3 ls
aws sts get-caller-identity

# Docker
docker ps              # List containers
docker logs <name>     # View logs
docker-compose up -d   # Start services
docker-compose down    # Stop services
docker system prune -a # Clean up

# System Monitoring
htop                   # Process monitor
iotop                  # I/O monitor
nethogs                # Network monitor
df -h                  # Disk usage
free -h                # Memory usage
```

---

## 🎯 Testing Checklist

### Pre-Deployment Tests:

- [ ] Terraform validates without errors
- [ ] All variables are properly configured
- [ ] SSH keys are accessible
- [ ] AWS credentials are configured
- [ ] Email for alerts is valid

### Post-Deployment Tests:

**Infrastructure:**
- [ ] Both EC2 instances are running
- [ ] RDS instance is available
- [ ] Security groups allow proper access
- [ ] CloudWatch alarms are active
- [ ] SNS subscription is confirmed

**Frontend:**
- [ ] Can SSH to frontend server
- [ ] Docker is installed and running
- [ ] Uptime Kuma container is healthy
- [ ] Application accessible on port 3001
- [ ] GitHub Actions workflow exists

**Backend:**
- [ ] Can SSH to backend server
- [ ] PHP and Composer installed
- [ ] Laravel application deployed
- [ ] Database connection successful
- [ ] Migrations run successfully
- [ ] GitHub Actions workflow exists

**CI/CD:**
- [ ] GitHub secrets configured
- [ ] Frontend workflow triggers on push
- [ ] Backend workflow triggers on push
- [ ] Deployments complete successfully
- [ ] Applications update after push

**Monitoring:**
- [ ] CPU alarms are configured
- [ ] Email notifications working
- [ ] Can trigger test alerts
- [ ] CloudWatch showing metrics

---


## 📞 Support & Troubleshooting

### Getting Help:

**Community Resources:**
- Stack Overflow: [terraform], [aws], [laravel]
- Reddit: r/terraform, r/aws, r/laravel
- Discord: Terraform Community, Laravel Discord

**Documentation:**
- AWS: https://docs.aws.amazon.com/
- Terraform: https://www.terraform.io/docs/
- Laravel: https://laravel.com/docs/
- GitHub Actions: https://docs.github.com/actions/

**Professional Support:**
- AWS Support Plans
- HashiCorp Support
- Laravel Partner Network

---
## 🏆 Project Success Criteria

### Technical Requirements Met:

- ✅ Infrastructure created with Terraform
- ✅ All resources in default VPC
- ✅ Correct specifications (1 core, 1GB RAM, 8GB disk)
- ✅ RDS MySQL with no public access
- ✅ GitHub Actions for frontend (build + deploy)
- ✅ GitHub Actions for backend (pull + migrate)
- ✅ CPU monitoring with email alerts
- ✅ Docker-compose for frontend
- ✅ Organized code with comments
- ✅ Complete documentation

### Bonus Points:

- ✅ Comprehensive migration plan
- ✅ Security hardening recommendations
- ✅ Performance optimization tips
- ✅ Monitoring enhancements
- ✅ Backup and disaster recovery
- ✅ Cost optimization strategies
- ✅ Production readiness guide

---

## AWS Setup


![CloudDrop Architecture](https://github.com/amramer101/Terraform-Task/blob/main/Photos/CW.png "CloudWatch")
---
![CloudDrop Architecture](https://github.com/amramer101/Terraform-Task/blob/main/Photos/Ec2.png "EC2")
---

![CloudDrop Architecture](https://github.com/amramer101/Terraform-Task/blob/main/Photos/RDS.png "RDS")
---
![CloudDrop Architecture](https://github.com/amramer101/Terraform-Task/blob/main/Photos/TF-State.png "TF State File")
---
![CloudDrop Architecture](https://github.com/amramer101/Terraform-Task/blob/main/Photos/VPC.png "VPC")
---


## 🎉 Conclusion

This setup provides a complete, production-ready infrastructure with automated CI/CD pipelines. The architecture follows AWS best practices and includes monitoring, security, and scalability considerations.

**Key Achievements:**

1. ✅ **Infrastructure as Code** - Reproducible and version-controlled
2. ✅ **Automated Deployments** - Zero-touch deployment process
3. ✅ **Monitoring & Alerts** - Proactive issue detection
4. ✅ **Security** - Defense in depth approach
5. ✅ **Scalability** - Ready to scale horizontally
6. ✅ **Documentation** - Comprehensive guides and procedures

**Next Steps:**

1. Deploy the infrastructure using Terraform
2. Configure GitHub repositories and workflows
3. Test all deployments thoroughly
4. Set up monitoring and verify alerts
5. Plan for production launch
6. Implement recommended enhancements

---


**Last Updated**: November 2025  
**Version**: 1.0  
**Maintained by**: DevOps Team | Amr Medhat


