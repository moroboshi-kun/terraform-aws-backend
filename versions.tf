# ===========================================
# File: versions.tf
# Date: 2026-02-04
# Description: Terraform configuration
#
# ===========================================

terraform {
  required_version = ">=1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}
