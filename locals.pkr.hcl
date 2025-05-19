locals {
  source_ami_id = data.amazon-ami.eks-al2023.id
  timestamp     = regex_replace(timestamp(), "[- TZ:]", "")
  ami_name      = "amazon-eks-node-${var.organization_name}-${var.eks_version}-al2023-${local.timestamp}"
  datetime      = formatdate("YYYY-MM-DD-hh-mm", timestamp())
  playbook_dir  = "./scripts/ansible"

  # Essential Python packages (needed for cloud-init and system tools)
  python_essential_packages = [
    "python${var.python_version}",
    "python${var.python_version}-libs",
    "python${var.python_version}-setuptools",
    "python${var.python_version}-pip-wheel",
    "python${var.python_version}-pip",
    "python3-policycoreutils"
  ]

  # Development Python packages (can be safely removed)
  python_dev_packages = [
    "python${var.python_version}-devel"
  ]

  # Combined packages for initial installation
  python_packages = concat(local.python_essential_packages, local.python_dev_packages)

  base_packages = [
    "unzip",
    "wget",
    "jq",
    "rsyslog-logrotate",
    "acl",
    "device-mapper-multipath"
  ]

  ad_packages = [
    "oddjob",
    "oddjob-mkhomedir",
    "sssd",
    "realmd",
    "krb5-workstation",
    "samba-common-tools",
    "adcli"
  ]

  ansible_collections = [
    "amazon.aws",
    "community.aws",
    "community.general",
    "community.crypto",
    "ansible.posix"
  ]
}