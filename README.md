# Terraform Configuration for Redis Cloud PRO Subscription and PrivateLink

This repository contains Terraform configurations for provisioning **Redis Cloud PRO databases** with **AWS PrivateLink** for secure private connectivity.

**Provider Version**: Redis Cloud Terraform Provider **2.10.1** (Updated January 2026)

**The configuration supports two modes:**

1. **Create a new subscription with a database** - Full setup from scratch
2. **Add a database to an existing subscription** - Extend existing infrastructure

**Features:**

- Redis 8.2 (includes all modules by default: RedisJSON, RediSearch, RedisBloom, RedisTimeSeries)
- Flexible billing (Marketplace or Credit Card)
- Security hardened (disabled default user, RBAC/ACL)
- Optional TLS enforcement
- AWS PrivateLink connectivity (replaces VPC Peering)
- Environment-aware region mapping

---

## Overview

This Terraform setup simplifies the creation and management of Redis Cloud PRO subscriptions and databases. It includes essential security configurations, API integration, and support for custom database settings, user access, and secure connectivity via **PrivateLink**.

**Two Usage Modes:**

### Mode 1: Create New Subscription + Database
Set `create_subscription = true` to create a complete new Redis Cloud PRO subscription with a database.

### Mode 2: Add Database to Existing Subscription
Set `create_subscription = false` and provide `existing_subscription_id` to add a database to an existing subscription.

You can deploy different environments by simply adjusting variables (e.g., `dev` in `us-east-1` vs. `prod` in `sa-east-1`). Region mapping is handled automatically unless overridden.

---

## Prerequisites

- Terraform (or [OpenTofu](https://opentofu.org)) >= 1.2 installed.
- Redis Cloud Terraform Provider 2.10.1
- Access to Redis Cloud API credentials.
- AWS API credentials (`aws_access_key` and `aws_secret_key`) if managing consumer-side Interface Endpoints.

---

## Variables

**Mode Control:**
- `create_subscription`: Boolean - `true` to create new subscription, `false` to use existing (default: `true`)
- `existing_subscription_id`: String - Required when `create_subscription = false`

**Common Variables (both modes):**
- `redis_global_api_key`: Your Redis Cloud API key
- `redis_global_secret_key`: Your Redis Cloud API secret key
- `database_name`: The name of the Redis Cloud database to be created
- `redis_version`: Redis version (default: `"8.2"` - includes all modules)
- `dataset_size_in_gb`: Dataset size limit in GB for the database
- `throughput_measurement_value`: Throughput in operations per second
- `replication`: Boolean for replication/HA
- `enable_tls`: Boolean to enable or disable TLS
- `user_password`: Password for the ACL user
- `tags`: Key-value map for resource tagging
- `environment`: Deployment environment (`dev` or `prod`) - Controls region mapping

**New Subscription Mode Only (when `create_subscription = true`):**
- `subscription_name`: The name of the Redis Cloud subscription to create
- `cloud_account_id`: The ID of your cloud provider account (use `1` for Redis-managed)
- `networking_deployment_cidr`: CIDR block for the subscription network
- `billing_mode`: Billing method (`marketplace` or `credit-card`)
- `card_type`: Payment card type (e.g., Visa, Mastercard) - only for credit-card mode
- `private_link_share_name`: Name for the PrivateLink share
- `private_link_principals`: List of principals (AWS account IDs, orgs, etc.) to grant access
- `region`: Optional manual region override (if empty, environment mapping applies)

---

## Key Features Configured

- **PrivateLink Connectivity:** Creates a Redis Cloud PrivateLink share to allow secure access from AWS VPCs.  
  AWS consumers can connect using an **Interface VPC Endpoint** to this share.
- **Marketplace or Credit Card Billing:** Choose billing mode dynamically.
- **Environment-Aware Deployments:** `dev → us-east-1`, `prod → sa-east-1`, or custom region override.
- **Security Hardening:** Disables the default user, enforces TLS (optional), and creates ACLs.
- **RBAC with ACL Roles and Users:** Fine-grained access control to databases.
- **Tagging:** Metadata organization for ownership and environment.

---

## Usage

### Option 1: Create New Subscription + Database

1. **Use the example file:**
   ```bash
   cp terraform.tfvars.NEW_SUBSCRIPTION.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars` with your values:**
   ```hcl
   create_subscription         = true
   redis_global_api_key        = "your-api-key"
   redis_global_secret_key     = "your-secret-key"
   subscription_name           = "your-subscription-name"
   database_name               = "your-database-name"
   redis_version               = "8.2"
   # ... other settings
   ```

3. **Run Terraform:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Option 2: Add Database to Existing Subscription

**Important:** Use a separate state file to avoid conflicts with your existing subscription state.

1. **Create a new tfvars file:**
   ```bash
   cp terraform.tfvars.EXISTING_SUBSCRIPTION.example terraform.tfvars.second-db
   ```

2. **Edit `terraform.tfvars.second-db` with your values:**
   ```hcl
   create_subscription         = false
   existing_subscription_id    = "12345678"  # Your existing subscription ID
   redis_global_api_key        = "your-api-key"
   redis_global_secret_key     = "your-secret-key"
   database_name               = "your-new-database-name"
   redis_version               = "8.2"
   # ... other database settings
   ```

3. **Run Terraform with a separate state file:**
   ```bash
   terraform init
   terraform plan -var-file=terraform.tfvars.second-db -state=terraform.tfstate.second-db
   terraform apply -var-file=terraform.tfvars.second-db -state=terraform.tfstate.second-db
   ```

   **Why separate state files?** Each Terraform state file tracks one set of resources. Using separate state files allows you to manage multiple databases independently without conflicts.

4. **Destroy when done:**
   ```bash
   # For main subscription
   terraform destroy

   # For additional databases (use the correct state file)
   terraform destroy -var-file=terraform.tfvars.second-db -state=terraform.tfstate.second-db
   ```

---

## Outputs

Key outputs after deployment include:

- `rediscloud_subscription_id` — Subscription ID (created or existing)
- `rediscloud_subscription_name` — Subscription name (only when created)
- `rediscloud_database_id` and `rediscloud_database_name` — Database details
- `rediscloud_database_public_endpoint` / `rediscloud_database_private_endpoint` — Connection endpoints
- `rediscloud_database_username` and `rediscloud_database_password` — ACL user credentials
- `rediscloud_privatelink_share_arn` — PrivateLink share ARN (only when subscription is created)
- `rediscloud_privatelink_databases` — Database PrivateLink endpoints (only when subscription is created)

---

## Security Notes

- **Sensitive Variables:** Do **not** commit credentials or passwords to version control.
- **State File:** Terraform state may contain sensitive info. Use secure remote backends (e.g., Terraform Cloud, AWS S3 + KMS).

---

## Quick Connect (redis-cli)

After deployment, you can connect using:

```bash
redis-cli --tls -h <private_or_public_endpoint> -p <port>   --user <database-user> --pass "<user_password>"
```

Replace placeholders with output values from `terraform apply`.

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.
