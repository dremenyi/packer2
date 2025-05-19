# AWS Regional Configuration
variable "aws_region" {
  type        = string
  description = "AWS region where the AMI will be built and stored"
}

variable "partition" {
  type        = string
  description = "AWS partition (e.g., 'aws', 'aws-cn', 'aws-us-gov')"
}

# EKS Configuration
variable "eks_version" {
  type        = string
  default     = "1.30"
  description = "Version of EKS to use for the AMI build"
}

# Infrastructure Configuration
variable "vpc_id" {
  type        = string
  description = "ID of the VPC where Packer will launch the builder instance"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet where Packer will launch the builder instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type to use for building the AMI"
}

# AMI Configuration
variable "source_ami_arch" {
  type        = string
  description = "Architecture of the source AMI (e.g., 'x86_64', 'arm64')"
}

variable "ami_owners" {
  type        = list(string)
  default     = []
  description = "List of AWS account IDs that own the source AMIs"
}

variable "resource_prefix" {
  type        = string
  description = "Prefix to be applied to resources created during the build process"
}

# AMI Sharing Configuration
variable "share_account_ids" {
  type        = list(string)
  default     = []
  description = "List of AWS account IDs to share the resulting AMI with"
}

variable "ami_groups" {
  type        = list(string)
  default     = []
  description = "List of groups with which the AMI will be shared (e.g., 'all' for public)"
}

variable "ami_org_arns" {
  type        = list(string)
  default     = []
  description = "List of AWS Organization ARNs to share the AMI with"
}

variable "ami_ou_arns" {
  type        = list(string)
  default     = []
  description = "List of AWS Organizational Unit ARNs to share the AMI with"
}

# Security Configuration
variable "ebs_kms_key_arn" {
  type        = string
  description = "ARN of the KMS key used for EBS volume encryption"
}

variable "custom_packer_role_name" {
  type        = string
  default     = null
  description = "Name of custom IAM role for Packer to use during build"
}

variable "custom_packer_instance_profile_name" {
  type        = string
  default     = null
  description = "Name of custom instance profile for Packer to use during build"
}

variable "builder_account_id" {
  type        = string
  default     = null
  description = "AWS account ID where the AMI builder instance will run"
}

# SSH Configuration
variable "ssh_keypair_name" {
  type        = string
  default     = null
  description = "Name of the SSH keypair to attach to the builder instance"
}

variable "ssh_private_key_file" {
  type        = string
  default     = null
  description = "Path to the SSH private key file for connecting to the builder instance"
}

# Tagging and Organization
variable "organization_name" {
  type        = string
  description = "Name of the organization for resource tagging"
}

variable "custom_tags" {
  type        = map(string)
  default     = {}
  description = "Map of custom tags to apply to the AMI and snapshots"
}

variable "environment" {
  type        = string
  default     = "Staging"
  description = "Environment designation for the AMI (e.g., 'Production', 'Staging')"
}

# System Configuration
variable "active_directory" {
  type        = bool
  default     = false
  description = "Whether to install Active Directory integration packages"
}

variable "ansible_role_path" {
  type        = string
  default     = "./scripts/ansible/roles/"
  description = "Base path to Ansible roles directory"
}

variable "packer_tmp_dir" {
  type        = string
  default     = "/opt/packer"
  description = "Temporary directory used for Packer operations on the builder instance"
}

variable "python_version" {
  type        = string
  default     = "3.11"
  description = "Version of Python to install for Ansible and other operations"
}

variable "ansible_version" {
  type        = string
  default     = "2.16.6"
  description = "Version of Ansible to install for configuration management"
}

variable "system_user" {
  type        = string
  default     = "ec2-user"
  description = "Default system user for the AMI"
}