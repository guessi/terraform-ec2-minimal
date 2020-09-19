# Manage EC2 with Terraform

Minimal setup for creating EC2 instance with customized boot up script

### Prerequisites

- AWS IAM User/Role with EC2 Full Access Permission
- Proper configured AWS profile (profile name: default)
- Terraform > 0.12

### Setup Guide

```bash
terraform init
terraform plan # review changes
terraform apply # apply changes
```
