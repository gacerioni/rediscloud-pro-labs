# Terraform Configuration for Redis Cloud PRO Subscription and PrivateLink

This repository contains Terraform configurations for provisioning **a Redis Cloud PRO subscription and database from scratch**, using **AWS PrivateLink** for secure private connectivity.

**The configuration is designed to:**

- Create a new Redis Cloud PRO subscription (supports Marketplace or Credit Card billing).
- Add a Redis Cloud PRO database within the subscription.
- Disable the default user for enhanced security.
- Optionally enforce TLS connections.
- Create a specific user with RBAC ACL for the database.
- Apply tags for metadata purposes.
- Establish a **PrivateLink** connection (instead of VPC Peering) for private access from AWS.

---

## Overview

This Terraform setup simplifies the creation and management of Redis Cloud PRO subscriptions and databases. It includes essential security configurations, API integration, and support for custom database settings, user access, and secure connectivity via **PrivateLink**.

You can deploy different environments by simply adjusting variables (e.g., `dev` in `us-east-1` vs. `prod` in `sa-east-1`). Region mapping is handled automatically unless overridden.

---

## Prerequisites

- Terraform (or [OpenTofu](https://opentofu.org)) installed.
- Access to Redis Cloud API credentials.
- AWS API credentials (`aws_access_key` and `aws_secret_key`) if managing consumer-side Interface Endpoints.

---

## Variables

**Key input variables (_customizable to your needs_):**

- `redis_global_api_key`: Your Redis Cloud API key.
- `redis_global_secret_key`: Your Redis Cloud API secret key.
- `subscription_name`: The name of the Redis Cloud subscription to create.
- `cloud_account_id`: The ID of your cloud provider account linked to Redis Cloud (use `1` for Redis-managed accounts).
- `environment`: Deployment environment (`dev` or `prod`). Controls region mapping.
- `region`: Optional manual region override (if empty, environment mapping applies).
- `database_name`: The name of the Redis Cloud database to be created.
- `dataset_size_in_gb`: Dataset size limit in GB for the database.
- `throughput_measurement_value`: Throughput in operations per second.
- `replication`: Boolean for replication/HA.
- `enable_tls`: Boolean to enable or disable TLS.
- `user_password`: Password for the ACL user.
- `tags`: Key-value map for resource tagging.
- `billing_mode`: Billing method (`marketplace` or `credit-card`).
- `card_type`: Payment card type (e.g., Visa, Mastercard).
- `private_link_share_name`: Name for the PrivateLink share.
- `private_link_principals`: List of principals (AWS account IDs, orgs, etc.) to grant access.

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

1. **Clone the repository:**
   ```bash
   git clone https://github.com/gacerioni/rediscloud-terraform-labs.git
   cd rediscloud-terraform-labs
   git checkout main
   ```

2. **Create a `terraform.tfvars` file (or environment-specific var file):**
   ```hcl
   redis_global_api_key        = "your-api-key"
   redis_global_secret_key     = "your-secret-key"
   subscription_name           = "your-subscription-name"
   cloud_account_id            = "1"
   database_name               = "your-database-name"
   dataset_size_in_gb          = 2
   throughput_measurement_value= 1000
   replication                 = false
   enable_tls                  = true
   user_password               = "Secret).42"
   environment                 = "dev"
   billing_mode                = "credit-card"
   card_type                   = "Mastercard"

   private_link_share_name = "my-redis-pl"
   private_link_principals = [
     {
       principal       = "123456789012"
       principal_type  = "aws_account"
       principal_alias = "dev-account"
     }
   ]

   tags = {
     environment = "dev"
     project     = "rediscloud-lab"
     owner       = "your-name"
   }
   ```

3. **Deploy with Terraform:**
   ```bash
   terraform init
   terraform plan -var-file=env/dev.tfvars
   terraform apply -var-file=env/dev.tfvars
   ```

4. **Destroy when done:**
   ```bash
   terraform destroy -var-file=env/dev.tfvars
   ```

---

## Outputs

Key outputs after deployment include:

- `rediscloud_subscription_id` and `rediscloud_subscription_name`
- `rediscloud_database_id` and `rediscloud_database_name`
- `rediscloud_database_public_endpoint` / `rediscloud_database_private_endpoint`
- `rediscloud_privatelink_share_arn` — ARN of the created PrivateLink share
- `rediscloud_privatelink_databases` — Database connection endpoints via PrivateLink

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
