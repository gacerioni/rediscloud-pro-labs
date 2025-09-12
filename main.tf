############################
# Env → Region mapping
############################
locals {
  env_region_map = {
    dev  = "us-east-1"
    prod = "sa-east-1"
  }
  # If var.region is set, use it; else use env mapping
  region_for_env = var.region != "" ? var.region : local.env_region_map[var.environment]
}

############################
# Redis Cloud PRO Subscription (Marketplace billing)
############################
resource "rediscloud_subscription" "pro_subscription" {
  name           = var.subscription_name
  payment_method = "marketplace"     # Marketplace billing (no payment_method_id)
  # IF YOU WANT TO TRY THE CREDIT CARD BILLING, UNCOMMENT THE NEXT LINE AND COMMENT THE PREVIOUS ONE
  #payment_method = "credit-card"    # Credit Card billing (requires payment_method_id
  #payment_method_id = "43521"
  memory_storage = "ram"

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
  creation_plan {
    dataset_size_in_gb           = var.dataset_size_in_gb
    quantity                     = 1
    replication                  = var.replication
    throughput_measurement_by    = "operations-per-second"
    throughput_measurement_value = var.throughput_measurement_value
    modules                      = var.modules
  }

  maintenance_windows {
    mode = "manual"
    window {
      start_hour         = 2
      duration_in_hours  = 4
      days               = ["Sunday"]
    }
  }
}

############################
# Database
############################
resource "rediscloud_subscription_database" "pro_redis_database" {
  subscription_id               = rediscloud_subscription.pro_subscription.id
  name                          = var.database_name
  redis_version                 = "7.4"
  dataset_size_in_gb            = var.dataset_size_in_gb
  data_persistence              = var.data_persistence
  throughput_measurement_by     = "operations-per-second"
  throughput_measurement_value  = var.throughput_measurement_value
  replication                   = var.replication
  enable_default_user           = false
  enable_tls                    = var.enable_tls
  tags                          = var.tags

  modules = [
    for module in var.modules : { name = module }
  ]

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
      subscription = rediscloud_subscription.pro_subscription.id
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
# (Optional) AWS VPC Peering (disabled by default)
############################
resource "rediscloud_subscription_peering" "aws_peering" {
  count           = var.enable_vpc_peering ? 1 : 0
  subscription_id = rediscloud_subscription.pro_subscription.id
  region          = local.region_for_env
  aws_account_id  = var.aws_account_id
  vpc_id          = var.aws_vpc_id
  vpc_cidr        = var.consumer_cidr
}

resource "aws_vpc_peering_connection_accepter" "aws_peering_accepter" {
  count                     = var.enable_vpc_peering ? 1 : 0
  vpc_peering_connection_id = rediscloud_subscription_peering.aws_peering[0].aws_peering_id
  auto_accept               = true
}