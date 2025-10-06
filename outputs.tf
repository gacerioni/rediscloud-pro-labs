output "rediscloud_subscription_id" {
  description = "The ID of the Redis Cloud subscription"
  value       = rediscloud_subscription.pro_subscription.id
}

output "rediscloud_subscription_name" {
  description = "The name of the Redis Cloud subscription"
  value       = rediscloud_subscription.pro_subscription.name
}

output "rediscloud_database_id" {
  description = "The ID of the Redis Cloud database"
  value       = rediscloud_subscription_database.pro_redis_database.id
}

output "rediscloud_database_name" {
  description = "The name of the Redis Cloud database"
  value       = rediscloud_subscription_database.pro_redis_database.name
}

output "rediscloud_database_public_endpoint" {
  description = "The public endpoint of the Redis Cloud database"
  value       = rediscloud_subscription_database.pro_redis_database.public_endpoint
}

output "rediscloud_database_private_endpoint" {
  description = "The private endpoint of the Redis Cloud database"
  value       = rediscloud_subscription_database.pro_redis_database.private_endpoint
}

output "rediscloud_database_replication" {
  description = "Whether replication is enabled for the Redis Cloud database"
  value       = rediscloud_subscription_database.pro_redis_database.replication
}

output "rediscloud_database_tls_enabled" {
  description = "Whether TLS is enabled for the Redis Cloud database"
  value       = rediscloud_subscription_database.pro_redis_database.enable_tls
}

output "rediscloud_database_protocol" {
  description = "The protocol used by the Redis Cloud database"
  value       = rediscloud_subscription_database.pro_redis_database.protocol
}

output "rediscloud_database_memory_limit_in_gb" {
  description = "The memory limit in GB for the Redis Cloud database"
  value       = rediscloud_subscription_database.pro_redis_database.memory_limit_in_gb
}

output "rediscloud_database_throughput_measurement" {
  description = "The throughput measurement value in operations-per-second"
  value       = rediscloud_subscription_database.pro_redis_database.throughput_measurement_value
}

output "rediscloud_database_username" {
  description = "The username for the Redis Cloud database"
  value       = rediscloud_acl_user.acl_user.name
}

output "rediscloud_database_password" {
  description = "The password for the Redis Cloud database (DEBUG)"
  value       = rediscloud_acl_user.acl_user.password
  sensitive   = true
}

# --- PrivateLink outputs ---
output "rediscloud_privatelink_share_arn" {
  description = "Share ARN of the Redis Cloud PrivateLink"
  value       = rediscloud_private_link.aws_privatelink.share_arn
}

output "rediscloud_privatelink_resource_configuration_arn" {
  description = "Resource configuration ARN for the PrivateLink"
  value       = rediscloud_private_link.aws_privatelink.resource_configuration_arn
}

output "rediscloud_privatelink_connections" {
  description = "List of PrivateLink connections"
  value       = rediscloud_private_link.aws_privatelink.connections
}

output "rediscloud_privatelink_databases" {
  description = "Databases and their PrivateLink endpoints (resource_link_endpoint)"
  value       = rediscloud_private_link.aws_privatelink.databases
}

# --- Removed: peering outputs ---
# rediscloud_peering_status
# aws_vpc_peering_id