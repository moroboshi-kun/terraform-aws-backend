# Terraform AWS Backend

This repository provisions a **remote Terraform backend on AWS**,
consisting of:

-   An S3 bucket for storing Terraform state
-   A DynamoDB table for state locking

It is intended to be deployed once per AWS account to provide durable,
shared backend infrastructure for other Terraform projects.

------------------------------------------------------------------------

# Architecture

## Foundational Infrastructure

-   S3 bucket (versioned, encrypted, private)
-   DynamoDB lock table (on-demand billing)

## Terraform Workloads

Other Terraform repositories use this backend via the S3 backend
configuration.

------------------------------------------------------------------------

# Quick Start (Recommended Workflow)

## 1. Clone the Repository

``` bash
git clone https://github.com/moroboshi-kun/terraform-aws-backend.git
cd terraform-aws-backend
```

## 2. Create `terraform.tfvars`

This template is designed to be used with a `terraform.tfvars` file.

Create a file named `terraform.tfvars` in the root of the repository:

``` hcl
# Important: Bucket name must be globally unique
state_bucket_name = "my-org-terraform-state-123456789012"

# Optional: override default DynamoDB lock table name
lock_table_name   = "terraform-locks"
```

## 3. Initialize and Apply

``` bash
terraform init
terraform apply
```

This creates:

-   The S3 backend bucket
-   The DynamoDB locking table

At this stage, the repository uses **local Terraform state**.

------------------------------------------------------------------------

# Configuration Details

## Supplying Variables Without `terraform.tfvars`

If you choose not to use a `terraform.tfvars` file, required variables
must be supplied explicitly:

``` bash
terraform apply   -var="state_bucket_name=my-org-terraform-state-123456789012"
```

To override the default DynamoDB lock table name:

``` bash
-var="lock_table_name=my-org-terraform-locks-123456789012"
```

## Important Notes

-   The S3 bucket name must be globally unique.
-   Backend resources are protected with `prevent_destroy`.
-   Backend infrastructure should be treated as foundational and stable.

------------------------------------------------------------------------

# Remote State Migration (Optional but Recommended)

After initial bootstrap, this repository can migrate its own state to
the S3 backend it created.

This eliminates dependency on a local `terraform.tfstate` file.

## Step 1 --- Ensure Clean State

``` bash
terraform plan
```

Expected:

    No changes. Infrastructure is up-to-date.

## Step 2 --- Add Backend Configuration

Create a file named `backend.tf`:

``` hcl
terraform {
  backend "s3" {
    bucket         = var.state_bucket_name
    key            = "root/backend.tfstate"
    region         = "us-east-1"
    dynamodb_table = var.lock_table_name
    encrypt        = true
  }
}
```

The `key` determines the state file location inside the bucket.
`root/backend.tfstate` is a logical name for foundational
infrastructure.

## Step 3 --- Migrate State

``` bash
terraform init -migrate-state
```

When prompted to copy existing state to the new backend, type:

    yes

## Step 4 --- Verify Migration

``` bash
terraform plan
```

Then confirm the state file exists:

``` bash
aws s3 ls s3://<bucket-name>/root/
```

## Step 5 --- Remove Local State Files

``` bash
rm -f terraform.tfstate terraform.tfstate.backup
```

The backend repository is now fully remote-managed.

------------------------------------------------------------------------

# Using This Backend in Other Terraform Projects

Example backend configuration for other Terraform repositories:

``` hcl
terraform {
  backend "s3" {
    bucket         = "my-org-terraform-state-123456789012"
    key            = "dev/network.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

Guidelines:

-   Each Terraform project must use a unique `key`.
-   The bucket and lock table are shared per AWS account.
-   Organize state files using logical prefixes (e.g., `dev/`, `prod/`,
    `infra/`).

------------------------------------------------------------------------

# Future Enhancement Option

This backend infrastructure can alternatively be provisioned via a
CloudFormation stack to eliminate bootstrap considerations.

This repository currently provisions the backend with Terraform and
supports migrating its own state to S3.

------------------------------------------------------------------------

# Summary

This repository:

1.  Creates Terraform backend infrastructure on AWS.
2.  Supports a clean, documented bootstrap workflow.
3.  Can migrate its own state to remote S3 storage.
4.  Provides durable backend infrastructure for all other Terraform
    projects.
