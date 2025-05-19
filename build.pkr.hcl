build {
  name    = "al2023-eks-cis"
  sources = ["source.amazon-ebs.eks"]

  # Create Packer temporary directory
  provisioner "shell" {
    inline = [
      "sudo mkdir -p ${var.packer_tmp_dir}/files",
      "sudo chown -R ${var.system_user}:root ${var.packer_tmp_dir}"
    ]
  }

  # Initial verification provisioner
  provisioner "shell" {
    inline = [
      "echo '=== Base AMI Information ==='",
      "cat /etc/eks/release || echo 'EKS release file not found'",
      "cat /etc/eks/kubelet-version.txt || echo 'Kubelet version file not found'",

      "echo '=== EKS Component Versions ==='",
      "containerd --version || echo 'Containerd not found'",
      "/usr/bin/kubelet --version || echo 'Kubelet not found'",
      "crictl --version || echo 'crictl not found'",

      "echo '=== EKS Directories ==='",
      "ls -la /etc/eks/ || echo '/etc/eks not found'",
      "ls -la /etc/kubernetes/ || echo '/etc/kubernetes not found'",
      "ls -la /var/lib/kubelet/ || echo '/var/lib/kubelet not found'",

      "echo '=== EKS Services ==='",
      "systemctl list-units --type=service --state=enabled | grep -E 'kubelet|containerd' || echo 'No EKS services found'",

      "echo '=== Container Runtime Setup ==='",
      "ls -la /etc/containerd/ || echo 'Containerd config not found'",
      "cat /etc/containerd/config.toml || echo 'Containerd config file not found'"
    ]
  }

  # Initial system update and reboot
  provisioner "shell" {
    expect_disconnect = true
    inline = [
      "sudo dnf -y update",
      "sudo reboot"
    ]
    pause_after = "30s"
  }

  # Install base packages
  provisioner "shell" {
    inline = concat(
      ["echo '=== Installing Base Packages ==='",
      "sudo dnf install -y ${join(" ", local.base_packages)}"],
      var.active_directory ?
      ["echo '=== Installing Active Directory Packages ==='",
      "sudo dnf install -y ${join(" ", local.ad_packages)}"] : []
    )
  }

  # FIPS configuration
  provisioner "shell" {
    expect_disconnect = true
    inline = [
      "echo '=== Enabling FIPS Mode ==='",
      "sudo dnf -y install crypto-policies crypto-policies-scripts",
      "sudo fips-mode-setup --enable",
      "sudo reboot"
    ]
  }

  # Post-reboot verification
  provisioner "shell" {
    pause_before = "60s"
    inline = [
      "echo '=== Verifying FIPS Status After Reboot ==='",
      "sudo fips-mode-setup --check",
      "update-crypto-policies --show",
      "echo 'FIPS_ENABLED=true' | sudo tee -a /etc/eks/release"
    ]
  }

  # Install Python and Ansible dependencies
  provisioner "shell" {
    inline = [
      "echo '=== Installing Python and Dependencies ==='",
      "sudo dnf install -y ${join(" ", local.python_packages)}",
      "sudo mkdir -p /usr/share/ansible/collections /opt/venv",
      "sudo chown -R ${var.system_user}:root /usr/share/ansible/collections /opt/venv",
      "umask 0022",
      "sudo /usr/bin/pip${var.python_version} install --upgrade cryptography"
    ]
  }

  # Setup Ansible
  provisioner "shell" {
    inline = concat([
      "echo '=== Setting up Ansible Environment ==='",
      "cd /opt/venv",
      "python${var.python_version} -m venv ansible",
      "source /opt/venv/ansible/bin/activate",
      "pip${var.python_version} install ansible-core==${var.ansible_version}",
      "pip${var.python_version} install --upgrade requests pyopenssl boto3 botocore"
      ],
      [for collection in local.ansible_collections :
        "ansible-galaxy collection install ${collection} -p /usr/share/ansible/collections"
    ])
  }

  # Partition Disk
  provisioner "ansible-local" {
    command                 = "source /opt/venv/ansible/bin/activate && ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook"
    playbook_file           = "${local.playbook_dir}/partition-disk.yml"
    playbook_dir            = local.playbook_dir
    role_paths              = ["${var.ansible_role_path}/partition_disk"]
    clean_staging_directory = false
    staging_directory       = "${var.packer_tmp_dir}/files"
    extra_arguments = [
      "-e", "ansible_python_interpreter=/opt/venv/ansible/bin/python3.11",
      "-e", "ansible_user=ec2-user"
    ]
  }

  # Reboot to ensure services do not use old directories
  provisioner "shell" {
    expect_disconnect = true
    inline = [
      "echo '=== Rebooting System to Apply Disk Partitioning Changes ==='",
      "sudo reboot"
    ]
    pause_after = "60s"
  }

  # Post Partition Disk Cleanup
  provisioner "shell" {
    inline = ["sudo rm -rf /var/log/audit-old /var/log-old /var/tmp-old /tmp-old /home-old /var-old"]
  }

  # Apply CIS Hardening
  provisioner "ansible-local" {
    command                 = "source /opt/venv/ansible/bin/activate && ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook"
    playbook_file           = "${local.playbook_dir}/al2023-eks-cis.yml"
    playbook_dir            = local.playbook_dir
    role_paths              = ["${var.ansible_role_path}/al2023_cis"]
    clean_staging_directory = false
    staging_directory       = "${var.packer_tmp_dir}/files"
    extra_arguments = [
      "-e", "ansible_python_interpreter=/opt/venv/ansible/bin/python3.11",
      "-e", "ansible_user=ec2-user",
      "-e", "amzn2023cis_rule_3_2_1=false"
    ]
  }

  # Reboot after CIS hardening
  provisioner "shell" {
    expect_disconnect = true
    remote_folder     = "/opt/packer"
    inline = [
      "echo '=== Rebooting System to Apply CIS Hardening Changes ==='",
      "sudo reboot"
    ]
    pause_after = "60s"
  }

  # Final EKS verification
  provisioner "shell" {
    remote_folder = "/opt/packer"
    inline = [
      "echo '=== Post-Install EKS Verification ==='",
      "/usr/bin/kubelet --version",
      "containerd --version",
      "crictl --version || echo 'crictl still not found'",
      "systemctl status containerd || echo 'containerd service not running'",
      "systemctl status kubelet || echo 'kubelet service not running'"
    ]
  }

  # Cleanup section at the end
  provisioner "shell" {
    remote_folder = "/opt/packer"
    inline = concat([
      "echo '=== Cleanup and Security Checks ==='",
      # Remove Ansible files
      "sudo rm -rf /usr/share/ansible /opt/venv",

      # Remove only development Python packages
      "sudo dnf remove -y ${join(" ", local.python_dev_packages)}",

      # Clean system files
      "sudo rm -rf /etc/machine-id",
      "sudo touch /etc/machine-id",
      "sudo rm -rf ${var.packer_tmp_dir}/*",
      "sudo shred -fu /etc/ssh/ssh_host_* || true",
      "sudo shred -fu /root/.ssh/authorized_keys || true",

      # Clean package manager
      "sudo dnf clean all",
      "sudo rm -rf /var/cache/dnf",
      "sudo rm -rf /root/.cache/pip",
      "sudo rm -rf /home/${var.system_user}/.cache/pip",

      # Set password expiry
      "sudo chage -M 9999 -m 9999 root",
      "sudo chage -M 9999 -m 9999 ${var.system_user}",
    ])
  }

  post-processor "manifest" {
    output     = "linux_manifest.json"
    strip_path = true
  }
}