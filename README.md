# Terraform AWS Modules Learning Project

This project demonstrates Terraform best practices using modular, reusable infrastructure-as-code. It creates a basic AWS infrastructure with networking and storage components.

## Resources Created

- **VPC** - Virtual Private Cloud network
- **Public Subnet** - Publicly routable subnet within the VPC
- **Internet Gateway** - Enables VPC internet connectivity
- **Public Route Table** - Routes traffic to IGW for public access
- **Security Group** - Firewall rules for inbound/outbound traffic
- **S3 Bucket** - Object storage with versioning and encryption

## Project Structure & File Interdependencies

### Core Configuration Files (Root Level)

#### 1. **versions.tf** *(Foundation)*
- **Purpose**: Defines Terraform and provider version constraints
- **Interdependencies**: 
  - Ensures compatibility with AWS provider
  - Must be read first before any provider initialization
- **Example**: Requires Terraform >= 1.5.0, AWS provider ~> 5.0

#### 2. **providers.tf** *(Configuration)*
- **Purpose**: Configures AWS provider and default tags
- **Interdependencies**: 
  - Depends on `versions.tf` constraints
  - Provides default tags to all resources in root module and child modules
  - Sets AWS region from `var.aws_region`
- **Flow**: `variables.tf` → `providers.tf` → applies to all resources

#### 3. **variables.tf** *(Input Parameters - Root Level)*
- **Purpose**: Declares root-level input variables
- **Key Variables**:
  - `aws_region` - AWS region for deployment
  - `project_name` - Used for resource naming convention
  - `environment` - Environment name (dev/staging/prod)
  - `vpc_cidr` - VPC network range
  - `public_subnet_cidr` - Subnet range
  - `bucket_name` - S3 bucket name (must be globally unique)
- **Interdependencies**:
  - Values passed to `main.tf` module calls
  - Read from `terraform.tfvars` at runtime
  - Forwarded to child modules as inputs

#### 4. **terraform.tfvars** *(Variable Values - NOT VERSIONED)*
- **Purpose**: Provides actual values for root variables
- **Interdependencies**:
  - Automatically loaded by Terraform at runtime
  - Overrides default values in `variables.tf`
  - Should NOT be committed to Git (in `.gitignore`)
- **Example**: `aws_region = "us-west-2"`, `bucket_name = "my-unique-bucket"`

#### 5. **terraform.tfvars.example** *(Template - VERSIONED)*
- **Purpose**: Template showing required variables for new developers
- **Interdependencies**:
  - Mirrors structure of `terraform.tfvars`
  - Safe to commit and share
  - Developers copy this to `terraform.tfvars` and fill in values

#### 6. **lookups.tf** *(Data Sources)*
- **Purpose**: Queries existing AWS resources to reference them
- **Interdependencies**:
  - Provides data about default VPC and subnets
  - Can be used by modules for reference data
  - Not currently used by main modules but available for expansion

#### 7. **main.tf** *(Module Orchestration)*
- **Purpose**: Instantiates and configures child modules
- **Module 1 - Networking**:
  ```hcl
  module "networking" {
    source = "./modules/networking"
    project_name       = var.project_name       # from variables.tf
    environment        = var.environment        # from variables.tf
    vpc_cidr           = var.vpc_cidr           # from variables.tf
    public_subnet_cidr = var.public_subnet_cidr # from variables.tf
  }
  ```
  - Passes variables to networking module
  - Creates networking infrastructure

- **Module 2 - S3 Bucket**:
  ```hcl
  module "s3_bucket" {
    source = "./modules/s3_bucket"
    bucket_name  = var.bucket_name  # from variables.tf
    project_name = var.project_name # from variables.tf
    environment  = var.environment  # from variables.tf
  }
  ```
  - Passes variables to S3 module
  - Creates storage infrastructure

- **Interdependencies**:
  - Reads from `variables.tf`
  - Calls child modules in `./modules/`
  - Creates resources that feed outputs to `outputs.tf`

#### 8. **outputs.tf** *(Export Values - Root Level)*
- **Purpose**: Exports important resource identifiers for users
- **Interdependencies**:
  - Reads from module outputs via `module.<name>.<output>`
  - Makes VPC ID, subnet ID, S3 bucket name/ARN available
  - Used by other Terraform projects or external systems
- **Example**:
  ```hcl
  output "vpc_id" {
    value = module.networking.vpc_id  # References networking module output
  }
  ```

---

### Module 1: Networking (`modules/networking/`)

#### **modules/networking/variables.tf**
- **Declares**: `project_name`, `environment`, `vpc_cidr`, `public_subnet_cidr`
- **Receives**: Values from `main.tf` module call
- **Used by**: Resources in `modules/networking/main.tf`

#### **modules/networking/main.tf**
- **Creates**:
  - `aws_vpc.main` - VPC with CIDR from `var.vpc_cidr`
  - `aws_subnet.public` - Public subnet with CIDR from `var.public_subnet_cidr`
  - `aws_internet_gateway.main` - IGW attached to VPC
  - `aws_route_table.public` - Routes for public subnet
  - `aws_route.internet_access` - Route to IGW (0.0.0.0/0)
  - `aws_security_group.public_sg` - Firewall rules
  
- **Interdependencies**:
  - VPC → Subnet (subnet must be in VPC)
  - VPC → IGW (IGW must be attached to VPC)
  - VPC → Route Table (route table belongs to VPC)
  - IGW → Route (route must reference IGW)
  - Route Table → Route Association (subnet routes through route table)
  - All use naming convention: `${var.project_name}-${var.environment}-<resource>`

#### **modules/networking/outputs.tf**
- **Exports**:
  - `vpc_id` - ID of created VPC
  - `public_subnet_id` - ID of created subnet
  - `security_group_id` - ID of created security group
- **Used by**: `root outputs.tf` and other modules that need network resources

---

### Module 2: S3 Bucket (`modules/s3_bucket/`)

#### **modules/s3_bucket/variables.tf**
- **Declares**: `bucket_name`, `project_name`, `environment`
- **Receives**: Values from `main.tf` module call
- **Used by**: Resources in `modules/s3_bucket/main.tf`

#### **modules/s3_bucket/main.tf**
- **Creates**:
  - `aws_s3_bucket.bucket` - S3 bucket with name from `var.bucket_name`
  - `aws_s3_bucket_versioning.versioning` - Enables version history
  - `aws_s3_bucket_server_side_encryption_configuration.encryption` - AES256 encryption
  - `aws_s3_bucket_public_access_block.public_access_block` - Blocks public access
  
- **Interdependencies**:
  - All resources depend on `aws_s3_bucket.bucket` existing first
  - Versioning → references bucket ID
  - Encryption → references bucket ID
  - Public access block → references bucket ID
  - All share naming pattern: `${var.project_name}-${var.environment}-bucket`

#### **modules/s3_bucket/outputs.tf**
- **Exports**:
  - `bucket_name` - Name of created bucket
  - `bucket_arn` - ARN (Amazon Resource Name) of bucket
- **Used by**: `root outputs.tf` and external systems needing bucket reference

---

## Data Flow Diagram

```
terraform.tfvars (values)
    ↓
variables.tf (root)
    ↓
    ├─→ providers.tf (AWS config + default tags)
    ├─→ main.tf (module calls)
    │    ├─→ module.networking
    │    │    ├─→ modules/networking/variables.tf
    │    │    ├─→ modules/networking/main.tf (creates resources)
    │    │    └─→ modules/networking/outputs.tf (exports VPC, subnet IDs)
    │    │
    │    └─→ module.s3_bucket
    │         ├─→ modules/s3_bucket/variables.tf
    │         ├─→ modules/s3_bucket/main.tf (creates resources)
    │         └─→ modules/s3_bucket/outputs.tf (exports bucket name, ARN)
    │
    └─→ outputs.tf (reads module.*.*.output values)
```

## Variable Cascade

1. **User defines values** → `terraform.tfvars`
2. **Root declares parameters** → `variables.tf`
3. **Root passes to modules** → `main.tf` module blocks
4. **Modules declare parameters** → `modules/*/variables.tf`
5. **Modules use parameters** → `modules/*/main.tf` resource blocks
6. **Modules export results** → `modules/*/outputs.tf`
7. **Root exports to users** → `outputs.tf`

## Naming Conventions

All resources follow the pattern: `${project_name}-${environment}-<resource-type>`

**Example** (with project_name="terraform-learning", environment="dev"):
- VPC: `terraform-learning-dev-vpc`
- Subnet: `terraform-learning-dev-public-subnet`
- IGW: `terraform-learning-dev-igw`
- Route Table: `terraform-learning-dev-public-rt`
- Security Group: `terraform-learning-dev-web-sg`
- S3 Bucket: `terraform-learning-dev-bucket`

## Default Tags

All AWS resources receive default tags from `providers.tf`:
- `Project` = project_name
- `Environment` = environment
- `ManagedBy` = "Terraform"
- `Owner` = "Biniyam"

These are automatically applied to all resources without duplication in code.

## Quick Start

### 1. Setup
```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
# - Change bucket_name to a globally unique name
# - Adjust aws_region if needed
nano terraform.tfvars
```

### 2. Initialize
```bash
terraform init
```

### 3. Preview
```bash
terraform plan
```

### 4. Deploy
```bash
terraform apply
```

### 5. Retrieve Outputs
```bash
terraform output
```

## Cleanup

```bash
terraform destroy
```
