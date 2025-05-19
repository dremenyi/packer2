# Packer IAM Requirements

## Required IAM Role Policy

This document outlines the IAM permissions required to run the EKS AL2023 CIS-hardened AMI build process.

### EC2 Permissions

Required for managing EC2 instances and AMI creation:
```json
{
    "Sid": "PackerEC2Perms",
    "Effect": "Allow",
    "Action": [
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:StopInstances",
        "ec2:CreateImage",
        "ec2:CreateTags",
        "ec2:RegisterImage",
        "ec2:DeregisterImage",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:DescribeSecurityGroups",
        "ec2:CreateKeypair",
        "ec2:DeleteKeyPair",
        "ec2:CreateSnapshot",
        "ec2:DeleteSnapshot",
        "ec2:DescribeSnapshots",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DescribeVolumes",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyImageAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:DescribeSubnets",
        "ec2:DescribeRegions",
        "ec2:DescribeTags",
        "ec2:GetPasswordData",
        "ec2:CopyImage"
    ],
    "Resource": "*"
}
```

### IAM Instance Profile Permissions

Required for managing instance profiles:
```json
{
    "Sid": "IAMPerms",
    "Effect": "Allow",
    "Action": [
        "iam:PassRole",
        "iam:GetInstanceProfile",
        "ec2:ReplaceIamInstanceProfileAssociation",
        "ec2:AssociateIamInstanceProfile"
    ],
    "Resource": "*"
}
```

### S3 Access

Required for accessing installation files:
```json
{
    "Sid": "ListObjectsInBucket",
    "Effect": "Allow",
    "Action": [
        "s3:ListBucket",
        "s3:GetObject"
    ],
    "Resource": [
        "arn:aws:s3:::your-bucket-name/*",
        "arn:aws:s3:::your-bucket-name"
    ]
}
```

### SSM Parameter Store Access

Required for accessing secure parameters:
```json
{
    "Sid": "PackerSSMParameterStore",
    "Effect": "Allow",
    "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath",
        "ssm:GetParameterHistory",
        "ssm:DescribeParameters",
        "ssm:ListTagsForResource"
    ],
    "Resource": [
        "arn:aws:ssm:region:account:parameter/your/parameter/paths/*"
    ]
}
```

### Global SSM Describe Permission

Additional SSM permission required:
```json
{
    "Effect": "Allow",
    "Action": "ssm:DescribeParameters",
    "Resource": "*"
}
```

### KMS Permissions

Required for EBS encryption:
```json
{
    "Sid": "PackerEBSEncrypt",
    "Effect": "Allow",
    "Action": [
        "kms:CreateGrant",
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
        "kms:ListGrants",
        "kms:ReEncrypt*"
    ],
    "Resource": "*"
}
```

## Complete Policy Example

Here's the complete IAM policy combining all the above permissions:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PackerEC2Perms",
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:StopInstances",
                "ec2:CreateImage",
                "ec2:CreateTags",
                "ec2:RegisterImage",
                "ec2:DeregisterImage",
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:CreateSecurityGroup",
                "ec2:DeleteSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:DescribeSecurityGroups",
                "ec2:CreateKeypair",
                "ec2:DeleteKeyPair",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot",
                "ec2:DescribeSnapshots",
                "ec2:CreateVolume",
                "ec2:DeleteVolume",
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:DescribeVolumes",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyImageAttribute",
                "ec2:ModifySnapshotAttribute",
                "ec2:DescribeSubnets",
                "ec2:DescribeRegions",
                "ec2:DescribeTags",
                "ec2:GetPasswordData",
                "ec2:CopyImage"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IAMPerms",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole",
                "iam:GetInstanceProfile",
                "ec2:ReplaceIamInstanceProfileAssociation",
                "ec2:AssociateIamInstanceProfile"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::your-bucket-name/*",
                "arn:aws:s3:::your-bucket-name"
            ]
        },
        {
            "Sid": "PackerSSMParameterStore",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:GetParametersByPath",
                "ssm:GetParameterHistory",
                "ssm:DescribeParameters",
                "ssm:ListTagsForResource"
            ],
            "Resource": [
                "arn:aws:ssm:region:account:parameter/your/parameter/paths/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "ssm:DescribeParameters",
            "Resource": "*"
        },
        {
            "Sid": "PackerEBSEncrypt",
            "Effect": "Allow",
            "Action": [
                "kms:CreateGrant",
                "kms:Decrypt",
                "kms:DescribeKey",
                "kms:Encrypt",
                "kms:GenerateDataKey*",
                "kms:ListGrants",
                "kms:ReEncrypt*"
            ],
            "Resource": "*"
        }
    ]
}
```

## Usage Notes

1. Replace placeholder values:
   - `your-bucket-name` with your S3 bucket name
   - `region` with your AWS region
   - `account` with your AWS account ID
   - `your/parameter/paths` with your SSM parameter paths

2. Security considerations:
   - Scope down the `Resource` sections where possible
   - Consider using more specific KMS key ARNs instead of "*"
   - Use specific VPC/Subnet IDs in resource ARNs where applicable

3. Required for features:
   - S3 permissions: Required if downloading assets from S3
   - SSM permissions: Required for accessing secure parameters
   - KMS permissions: Required for EBS volume encryption
   - EC2 permissions: Core functionality for AMI building
   - IAM permissions: Required for instance profile association

## Minimum Required Permissions

For basic functionality without optional features, you need at least:
- All EC2 permissions listed
- IAM instance profile permissions
- KMS permissions for EBS encryption

## Optional Permissions

Depending on your configuration:
- S3 permissions if using S3 assets
- SSM permissions if using Parameter Store
- Additional KMS permissions for custom key usage