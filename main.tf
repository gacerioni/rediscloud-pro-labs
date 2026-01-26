############################
# Env → Region mapping
############################
locals {
  # Map environment to default AWS Region
  env_region_map = {
    dev  = "us-east-1"
    prod = "sa-east-1"
  }

  # If var.region is set, use it; else use env default
  region_for_env = var.region != "" ? var.region : local.env_region_map[var.environment]

  # Determine which subscription ID to use
  subscription_id = var.create_subscription ? rediscloud_subscription.pro_subscription[0].id : var.existing_subscription_id
}

############################
# Payment method lookup (only when using credit-card AND creating new subscription)
# - We set count = 1 only if billing_mode == "credit-card" and create_subscription == true
# - For marketplace or existing subscription, this data source is skipped entirely.
############################
data "rediscloud_payment_method" "card" {
  count     = var.create_subscription && var.billing_mode == "credit-card" ? 1 : 0
  card_type = var.card_type
}

# Resolve the payment method id only in credit-card mode when creating subscription
locals {
  selected_payment_method_id = var.create_subscription && var.billing_mode == "credit-card" ? data.rediscloud_payment_method.card[0].id : null
}

############################
# Redis Cloud PRO Subscription
# - Billing is conditional:
#     * marketplace:  payment_method="marketplace" (no payment_method_id)
#     * credit-card:  payment_method="credit-card" + payment_method_id
############################
resource "rediscloud_subscription" "pro_subscription" {
  count = var.create_subscription ? 1 : 0

  name           = var.subscription_name
  memory_storage = "ram"

  payment_method    = var.billing_mode
  payment_method_id = var.billing_mode == "credit-card" ? local.selected_payment_method_id : null

  cloud_provider {
    provider         = "AWS"
    cloud_account_id = var.cloud_account_id

    region {
      region                       = local.region_for_env
      multiple_availability_zones  = true
      networking_deployment_cidr   = var.networking_deployment_cidr
      preferred_availability_zones = var.preferred_availability_zones
    }
  }

  # Initial creation plan (hardware profile)
  # Note: modules are NOT specified here for Redis 8+ compatibility
  # Modules are specified at the database level instead
  creation_plan {
    dataset_size_in_gb           = var.dataset_size_in_gb
    quantity                     = 1
    replication                  = var.replication
    throughput_measurement_by    = "operations-per-second"
    throughput_measurement_value = var.throughput_measurement_value
  }

  maintenance_windows {
    mode = "manual"
    window {
      start_hour        = 2
      duration_in_hours = 4
      days              = ["Sunday"]
    }
  }

  # Helpful guardrail:
  # If user chooses credit-card but we couldn’t resolve a method, fail early.
  lifecycle {
    precondition {
      condition     = !var.create_subscription || var.billing_mode != "credit-card" || local.selected_payment_method_id != null
      error_message = "billing_mode is 'credit-card' but no payment method was found for card_type='${var.card_type}'. Check your account payment methods or adjust variables."
    }
  }
}

############################
# Database
# - redis_version must be set here (subscription-level redis_version is deprecated).
############################
resource "rediscloud_subscription_database" "pro_redis_database" {
  subscription_id               = local.subscription_id
  name                          = var.database_name
  redis_version                 = var.redis_version
  dataset_size_in_gb            = var.dataset_size_in_gb
  data_persistence              = var.data_persistence
  throughput_measurement_by     = "operations-per-second"
  throughput_measurement_value  = var.throughput_measurement_value
  replication                   = var.replication
  enable_default_user           = false
  enable_tls                    = var.enable_tls
  tags                          = var.tags

  # Redis 8+ includes all modules by default - do not specify modules

  alert {
    name  = "dataset-size"
    value = var.dataset_size_alert_percentage
  }
}

############################
# ACLs
############################
resource "rediscloud_acl_role" "acl_role" {
  name = "${var.database_name}-role"

  rule {
    name = var.acl_rule_name
    database {
      subscription = local.subscription_id
      database     = rediscloud_subscription_database.pro_redis_database.db_id
    }
  }

  depends_on = [rediscloud_subscription_database.pro_redis_database]
}

resource "rediscloud_acl_user" "acl_user" {
  name     = "${var.database_name}-user"
  role     = rediscloud_acl_role.acl_role.name
  password = var.user_password

  depends_on = [rediscloud_acl_role.acl_role]
}

############################
# PrivateLink (replaces VPC peering)
# - Creates the PrivateLink share and allowlists principals (AWS accounts, orgs, etc).
# - Your AWS consumer VPC will still need to create an Interface VPC Endpoint to consume it.
# - Only created when creating a new subscription (PrivateLink is subscription-level)
############################
resource "rediscloud_private_link" "aws_privatelink" {
  count = var.create_subscription ? 1 : 0

  subscription_id = local.subscription_id
  share_name      = var.private_link_share_name

  # Add one 'principal' block per allowed principal using a dynamic block over the input list.
  dynamic "principal" {
    for_each = var.private_link_principals
    content {
      principal       = principal.value.principal
      principal_type  = principal.value.principal_type  # aws_account | organization | organization_unit | iam_role | iam_user | service_principal
      principal_alias = try(principal.value.principal_alias, null)
    }
  }
}