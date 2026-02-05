# ===========================================
# File: providers.tf
# Date: 2026-02-03
# Description: Terraform provider
#               configuration
#
# ===========================================

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}