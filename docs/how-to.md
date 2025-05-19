# Guide to Building CIS Hardened EKS AMI
A guide for building a CIS-compliant, FIPS-enabled EKS AMI based on the official AWS EKS-optimized AMI.

## Project Structure

```plaintext
.
├── build.pkr.hcl           # Main Packer build configuration
├── variables.pkr.hcl       # Variable definitions
├── vars/
│   └── variables.pkrvars.hcl  # Variable values
└── scripts/
    └── ansible/
        ├── al2023-eks-cis.yml     # Main CIS hardening playbook
        └── roles/
            └── al2023_cis/        # CIS benchmark implementation
```

## CIS Hardening Overview

The AMI is hardened according to CIS benchmarks through the `al2023-eks-cis.yml` Ansible playbook, which implements:

1. Section 1: Initial Setup
   - Filesystem configuration
   - Software updates
   - Secure boot settings
   - Additional security software

2. Section 2: Services
   - Network services
   - Service clients
   - Special purpose services

3. Section 3: Network Configuration
   - Network parameters
   - TCP wrappers
   - Firewall configuration

4. Section 4: Logging and Auditing
   - Configure system accounting
   - Audit system configuration

5. Section 5: Access, Authentication and Authorization
   - Access control configuration
   - PAM and password settings
   - User accounts and environment

6. Section 6: System Maintenance
   - System file permissions
   - User and group settings

## Key Security Features

1. CIS Compliance:
   - Implements CIS Amazon Linux 2023 benchmarks
   - Automated compliance checking
   - Security baseline enforcement

2. FIPS Mode:
   - FIPS 140-2 validated cryptographic modules
   - Secure communication enforcement
   - Compliant cryptographic operations

3. EKS Optimization:
   - Built on official EKS AMI base
   - Maintains EKS compatibility
   - Includes required EKS components