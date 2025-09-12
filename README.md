# Terraform Configuration for Redis Cloud PRO Subscription and Database

This repository contains Terraform configurations for provisioning **a Redis Cloud PRO subscription and database from scratch**.

**The configuration is designed to:**

- Create a new Redis Cloud PRO subscription (Marketplace-based billing).
- Add a Redis Cloud PRO database within the subscription.
- Disable the default user to enhance security.
- Optionally enforce TLS connections based on configuration.
- Create a specific user with RBAC ACL for the database.
- Apply tags for metadata purposes.
- Provide optional AWS VPC peering integration (disabled by default, ready for future PrivateLink v2).

---

## Overview

This Terraform setup simplifies the creation and management of Redis Cloud PRO subscriptions and databases. It includes essential security configurations, API integration, and support for custom database settings, user access, and security features such as TLS and RBAC.

You can deploy different environments by simply adjusting variables (e.g., `dev` in `us-east-1` vs. `prod` in `sa-east-1`). Region mapping is handled automatically unless overridden.

## Prerequisites

- Terraform (or [OpenTofu](https://opentofu.org)) installed on your machine.
- Access to Redis Cloud API credentials.
- Optional: AWS API credentials (`aws_access_key` and `aws_secret_key`) — only needed if enabling VPC peering.

## Variables

**Key input variables (_customizable to your needs_):**

- `redis_global_api_key`: Your Redis Cloud API key.
- `redis_global_secret_key`: Your Redis Cloud API secret key.
- `subscription_name`: The name of the Redis Cloud subscription to create.
- `cloud_account_id`: The ID of your cloud provider account linked to Redis Cloud. Use `1` for Redis-managed accounts.
- `environment`: Deployment environment (`dev` or `prod`). Controls default region mapping.
- `region`: Optional manual region override (if empty, environment mapping applies).
- `database_name`: The name of the new Redis Cloud database to be created.
- `dataset_size_in_gb`: The dataset size limit in GB for the database.
- `throughput_measurement_value`: The desired throughput in operations per second.
- `replication`: Boolean to enable or disable replication (High Availability).
- `enable_tls`: Boolean to enable or disable TLS for database connections.
- `user_password`: The password for the specific user created for RBAC ACL.
- `tags`: A map of tags to associate with the subscription and database for metadata purposes.
- `enable_vpc_peering`: Boolean to enable AWS VPC peering resources (default: false).

---

## Key Features Configured

- **Marketplace Billing:** No need for payment method IDs, just set `payment_method = "marketplace"`.
- **Environment-Aware Deployments:** `dev → us-east-1`, `prod → sa-east-1`, or override with `region` variable.
- **Disabling the Default User:** Enhances security by removing default access credentials.
- **TLS Enforcement:** Optionally enforce TLS for secure connections to the database.
- **RBAC and ACL Configuration:** Creates a specific user and role with defined ACLs for controlled access.
- **Tagging:** Apply custom tags for better resource organization and metadata management.
- **Optional VPC Peering:** Ready to be enabled if needed; by default disabled until PrivateLink v2 support arrives.

## Usage

**To use this Terraform configuration, follow these steps:**

1. Clone the Repository:
```bash
git clone https://github.com/gacerioni/rediscloud-terraform-labs.git
cd rediscloud-terraform-labs
git checkout main   # uses tf_pro_workshop as base
```

2. Create a `terraform.tfvars` File (or environment-specific `env/dev.tfvars`, `env/prod.tfvars`):
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
tags = {
  environment = "dev"
  project     = "my-project"
  owner       = "your-name"
}
```

3. Initialize Terraform and deploy:
```bash
terraform init
terraform plan -var-file=env/dev.tfvars   # for dev
terraform apply -var-file=env/dev.tfvars

terraform plan -var-file=env/prod.tfvars  # for prod
terraform apply -var-file=env/prod.tfvars

terraform destroy -var-file=env/dev.tfvars
```

---

## Security Notes

- **Sensitive Variables:** Ensure that sensitive information like `redis_global_api_key`, `redis_global_secret_key`, and `user_password` are stored securely. Do not commit them to version control.
- **State File Security:** The Terraform state file (`terraform.tfstate`) may contain sensitive information. Use secure backends (e.g., Terraform Cloud, S3 with encryption) when possible.

---

## Contributing

Contributions to this project are welcome. Please follow GitHub Flow (branch → PR → review → merge).

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Quick Connect (redis-cli)

Once deployed, you can connect to your Redis instance like this:

```bash
redis-cli --tls -h <private_or_public_endpoint> -p <port> \
  --user <database-user> --pass "<user_password>"
```

Replace placeholders with the output values after `terraform apply`.
