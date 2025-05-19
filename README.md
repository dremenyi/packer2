# AL2023 CIS-Hardened EKS AMI

## ⚠️ Important Note
This repository contains a one-time client request to build a CIS-hardened, FIPS-enabled AL2023 EKS AMI. This is **NOT** part of our officially maintained Packer codebase.

## Overview
This project builds a custom AL2023 EKS AMI that:
- Uses the official [amazon-eks-ami](https://github.com/awslabs/amazon-eks-ami) as a base
- Implements CIS benchmarks for Amazon Linux 2023
- Enables FIPS mode
- Includes custom partitioning
- Has been validated for EKS worker node compatibility

## Client-Specific Use Case
This codebase was developed to meet specific client requirements for:
- CIS compliance
- FIPS enablement
- Custom security controls
- EKS worker node functionality

## Validation
The AMI built using this code has been tested and validated. See `eks-validation-test.md` for test results and validation procedures.