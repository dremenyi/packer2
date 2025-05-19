data "amazon-ami" "eks-al2023" {
  filters = {
    architecture        = var.source_ami_arch
    name                = "amazon-eks-node-al2023-${var.source_ami_arch}-standard-${var.eks_version}-v*"
    root-device-type    = "ebs"
    state               = "available"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = var.ami_owners
  region      = var.aws_region
  assume_role {
    role_arn     = var.custom_packer_role_name == null ? "arn:${var.partition}:iam::${var.builder_account_id}:role/packer_role" : "arn:${var.partition}:iam::${var.builder_account_id}:role/${var.custom_packer_role_name}"
    session_name = "packer_session"
  }
}