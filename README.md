# Terraform AWS Backend Bootstrap

This repository bootstraps a **remote Terraform backend on AWS** using:

- **Amazon S3** for Terraform state storage
- **Amazon DynamoDB** for state locking and concurrency control

It is intended to be used as a **GitHub template** and run **once per AWS account** to create the foundational infrastructure that all other Terraform projects will rely on.

---

## What This Creates

This project provisions the following AWS resources:

### S3 Bucket (Terraform State)

- Stores Terraform state files
- Versioning enabled (for state recovery)
- Server-side encryption enabled
- All public access blocked
- `prevent_destroy` enabled to guard against accidental deletion

### DynamoDB Table (State Locking)

- Used for Terraform state locking
- `PAY_PER_REQUEST` billing mode
- Point-in-Time Recovery (PITR) enabled
- `prevent_destroy` enabled

This project **intentionally uses local Terraform state**.  
The remote backend it creates is meant to be consumed by _other_ Terraform projects.

---

## When to Use This Template

Use this repository when:

- Bootstrapping a new AWS account for Terraform usage
- Establishing a shared, standardized Terraform backend
- Preparing for CI/CD-driven Terraform workflows
- Replacing manually created or ad-hoc Terraform backends

This repository is typically run **once**, then left unchanged.

---

## Terraform & Provider Versions

- **Terraform:** tested with **Terraform v1.14.4**
- **Terraform version constraint:** compatible with modern Terraform releases
- **AWS Provider:** constrained to a compatible major version range

Exact versions are not pinned to allow flexibility for downstream users.

---

## Prerequisites

- Terraform installed locally
- AWS credentials configured (environment variables, AWS config, or IAM role)
- Permissions to create:
  - S3 buckets
  - DynamoDB tables

---

## Usage

### 1. Create a repository from this template

In GitHub, click **“Use this template”** to create a new repository for your AWS account.

---

### 2. Initialize Terraform

```bash
terraform init
```

---

### 3. Define input variables (recommended)

This template is designed to be used with a `terraform.tfvars` file.

Create a file named `terraform.tfvars` in the root of the repository:

```hcl
# Important: Bucket name must be globally unique
state_bucket_name = "my-org-terraform-state-123456789012"

# Optional: override the default DynamoDB lock table name
lock_table_name   = "terraform-locks"
```

---

### 4. Apply the configuration

With `terraform.tfvars` in place, apply the configuration:

```bash
terraform apply
```

This is the **recommended and expected workflow** for this template.

---

If you choose not to use a `terraform.tfvars` file, you must supply required variables explicitly.

```bash
# Important: You must supply a globally unique S3 Bucket name
terraform apply \
  -var="state_bucket_name=my-org-terraform-state-123456789012"
```

To override the default DynamoDB lock table name (`terraform-locks)`, include:

```bash
  -var="lock_table_name=my-org-terraform-locks-123456789012"
```

⚠️ **Important:**  
The resources created by this project are protected with `prevent_destroy` and should **not be destroyed** once in use.

---

## Outputs

After a successful apply, Terraform outputs:

- `state_bucket_name` – the S3 bucket storing Terraform state
- `lock_table_name` – the DynamoDB table used for state locking

These values are used when configuring the backend in other Terraform projects.

---

## Using This Backend in Other Terraform Projects

Example `backend "s3"` configuration:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-org-terraform-state-123456789012"
    key            = "prod/vpc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### Notes

- Each Terraform project **must use a unique `key`**
- Multiple projects can safely share:
  - The same S3 bucket
  - The same DynamoDB table
- State isolation is achieved via the S3 key

---

## Design Decisions & Conventions

### One Backend per AWS Account

This template follows the common pattern of:

- One S3 bucket per AWS account
- One DynamoDB lock table per AWS account
- Many Terraform projects sharing the same backend infrastructure

---

### `terraform.lock.hcl`

This repository **does not commit `terraform.lock.hcl` by design**.

Because this project is intended to be used as a **template**, committing the lock file would:

- Add noise for first-time users
- Immediately become stale after cloning
- Provide limited benefit for a one-time bootstrap project

Downstream Terraform projects are encouraged to commit their own `terraform.lock.hcl` files as appropriate.

---

## What This Repository Does _Not_ Do

- It does not manage application or environment infrastructure
- It does not configure CI/CD pipelines
- It does not store its own Terraform state remotely

Those responsibilities belong in downstream Terraform repositories.

---

## License

MIT
