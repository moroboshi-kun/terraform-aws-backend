# ===========================================
# File: variables.tf
# Date: 2026-02-04
# Description: Terraform variables file
#
# ===========================================

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "state_bucket_name" {
  # default value left blank to force user to provide a unique name
  type        = string
  description = "Globally unique S3 bucket name for Terraform state"
}

variable "lock_table_name" {
  type        = string
  default     = "terraform-locks" # override as needed
  description = "DynamoBD table name for Terraform state locking"

}
locals {
  account_id = data.aws_caller_identity.current.account_id
}
