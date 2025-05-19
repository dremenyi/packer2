## Coalfire Edits
Pulled from original repo at this commit time:
https://github.com/ansible-lockdown/AMAZON2023-CIS/commit/9f87aa72d06b46e4b9f4c0763b0292c8f2086265

Used devel branch for greater compatibility with Ansible-core 2.12 and higher.

Added handlers as it was missing from original code, even though tasks referred to them:
```
- name: remount home
  command: mount -o remount /home
  args:
      warn: false

- name: remount var_tmp
  command: mount -o remount /var/tmp
  args:
      warn: false
```

Review defaults > main.yml for "Coalfire Edit" in comments to see changes from original.

Altered RegEx on Patch 4.6.5 due to specific re.error from Python3.11:

https://github.com/fail2ban/fail2ban/issues/3314


Altered cis_4.6.x.yml, commented out "/etc/bashrc" from loop items, system services such as dbus and systemd-networkd will fail when umask in this file is set to 027, leading to a failure of the EC2 instance to obtain an IP address from DHCP.  **This doesn't provent the Packer AMI from building successfully, but if you launch an instance from the AMI, basic services such as dbus-broker.service will fail to start and the instance will have no basic networking.**

https://github.com/ansible-lockdown/AMAZON2023-CIS/issues/80


Altered task "1.2.4 | AUDIT | Ensure repo_gpgcheck is globally activated" to exclude "amazonlinux.repo" and "kernel-livepatch.repo" (the default AL2023 repos) because AWS does not support metadata signing (packages themselves are signed and transfers are via https):

https://github.com/amazonlinux/amazon-linux-2023/issues/336

- Modified tasks => cis_1.6.1.x.yml "1.6.1.3 | PATCH | Ensure SELinux policy is configured" and "1.6.1.4 | PATCH | Ensure the SELinux state is not disabled" and "1.6.1.5 | PATCH | Ensure the SELinux state is enforcing"
  - Removed module "ansible.posix.selinux" with "ansible.builtin.lineinfile" to manage SELinux configurations.
  - The SELinux module is not compatible with Python3.11 because SELinux bindings don't exist for that version: https://github.com/amazonlinux/amazon-linux-2023/issues/560


- Modified tasks => cis_4.4.x.yml "4.4.2 | PATCH | Ensure authselect includes with-faillock | Create custom profiles"
  - Added "--force" flag to overwrite files.