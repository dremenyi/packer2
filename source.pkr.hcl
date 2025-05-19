source "amazon-ebs" "eks" {
  aws_polling {
    # Default value is 40, increasing to avoid timeout during encryption
    # https://developer.hashicorp.com/packer/plugins/builders/amazon#resourcenotready-error
    delay_seconds = 30
    max_attempts  = 80
  }

  # AMI configurations
  ami_description = "EKS Kubernetes Worker AMI on Amazon Linux 2023 image (k8s: ${var.eks_version})"
  ami_name        = local.ami_name
  source_ami      = local.source_ami_id
  ssh_username    = "ec2-user"

  # AMI sharing configurations - only apply if values provided
  ami_users    = length(var.share_account_ids) > 0 ? var.share_account_ids : null
  ami_groups   = length(var.ami_groups) > 0 ? var.ami_groups : null
  ami_org_arns = length(var.ami_org_arns) > 0 ? var.ami_org_arns : null
  ami_ou_arns  = length(var.ami_ou_arns) > 0 ? var.ami_ou_arns : null

  # Instance configurations
  associate_public_ip_address = true
  ebs_optimized               = true
  encrypt_boot                = true
  imds_support                = "v2.0"
  instance_type               = var.instance_type
  region                      = var.aws_region
  subnet_id                   = var.subnet_id
  vpc_id                      = var.vpc_id

  # Tags
  run_tags = {
    Name              = local.ami_name
    OSType            = "Linux"
    BuildDate         = local.datetime
    Benchmark         = "cis"
    SecureBoot        = true
    KubernetesVersion = var.eks_version
    Distribution      = "Amazon Linux 2023"
    CreatedBy         = "Packer"
    BaseAMI           = local.source_ami_id
    Environment       = var.environment
    Organization      = var.organization_name
    Purpose           = "EKS Node"
    PatchLevel        = formatdate("YYYY-MM", timestamp())
  }

  tags = merge({
    Name              = local.ami_name
    OSType            = "Linux"
    BuildDate         = local.datetime
    Benchmark         = "cis"
    SecureBoot        = true
    KubernetesVersion = var.eks_version
    Distribution      = "Amazon Linux 2023"
    CreatedBy         = "Packer"
    BaseAMI           = local.source_ami_id
    Environment       = var.environment
    Organization      = var.organization_name
    Purpose           = "EKS Node"
    PatchLevel        = formatdate("YYYY-MM", timestamp())
  }, var.custom_tags)

  # Optional IAM profile
  dynamic "assume_role" {
    for_each = var.custom_packer_role_name != null || var.builder_account_id != null ? [1] : []
    content {
      role_arn     = var.custom_packer_role_name == null ? "arn:${var.partition}:iam::${var.builder_account_id}:role/packer_role" : "arn:${var.partition}:iam::${var.builder_account_id}:role/${var.custom_packer_role_name}"
      session_name = "packer_session"
    }
  }

  # Optional instance profile
  iam_instance_profile = var.custom_packer_instance_profile_name != null ? var.custom_packer_instance_profile_name : null

  # Storage configuration
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sdb"
    volume_size           = 50
    volume_type           = "gp3"
  }
  kms_key_id = var.ebs_kms_key_arn

  # SSH configuration - only if needed
  ssh_keypair_name     = var.ssh_keypair_name != null ? var.ssh_keypair_name : null
  ssh_private_key_file = var.ssh_private_key_file != null ? var.ssh_private_key_file : null
}