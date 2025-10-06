variable "redis_global_api_key" {
  description = "Global API key for Redis Cloud account"
  type        = string
  default     = "incorrect"
  sensitive   = true
}

variable "redis_global_secret_key" {
  description = "Global API Secret (USER KEY) for Redis Cloud account"
  type        = string
  default     = "incorrect"
  sensitive   = true
}

variable "aws_access_key" {
  description = "AWS Access Key (optional; only needed if you also manage AWS-side resources here)"
  type        = string
  sensitive   = true
  default     = null
}

variable "aws_secret_key" {
  description = "AWS Secret Key (optional; only needed if you also manage AWS-side resources here)"
  type        = string
  sensitive   = true
  default     = null
}

variable "subscription_name" {
  description = "The name of the RedisCloud subscription"
  type        = string
}

variable "cloud_account_id" {
  description = "Cloud account ID for the AWS provider"
  type        = string
  default     = "6415" # Use the correct value for your account
}

variable "database_name" {
  description = "The name of the RedisCloud database"
  type        = string
  default     = "test-db"
}

variable "dataset_size_in_gb" {
  description = "Memory limit in GB for the database"
  type        = number
  default     = 5
}

variable "data_persistence" {
  description = "Data persistence setting"
  type        = string
  default     = "none"
}

variable "throughput_measurement_value" {
  description = "Throughput measurement in operations per second"
  type        = number
  default     = 5000
}

variable "modules" {
  description = "List of Redis modules to enable"
  type        = list(string)
  default     = ["RedisJSON", "RediSearch", "RedisBloom", "RedisTimeSeries"]
}

variable "replication" {
  description = "Whether or not replication should be enabled"
  type        = bool
  default     = false
}

variable "acl_rule_name" {
  description = "ACL rule name for the database"
  type        = string
  default     = "Full-Access"
}

variable "enable_tls" {
  description = "Enable TLS for the database"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Custom tags for the database"
  type        = map(string)
  default     = {
    market = "brazil"
  }
}

variable "user_password" {
  description = "Password for the ACL user"
  type        = string
  sensitive   = true
  default     = "G4bZ#N3rd0l4.!"
}

variable "region" {
  description = "AWS region for the subscription (leave empty to use env defaults)"
  type        = string
  default     = ""
}

variable "preferred_availability_zones" {
  description = "Preferred availability zones for the subscription"
  type        = list(string)
  default     = []
}

variable "networking_deployment_cidr" {
  description = "CIDR block for the subscription networking deployment"
  type        = string
  default     = "10.123.42.0/24"
}

variable "dataset_size_alert_percentage" {
  description = "Alert threshold for dataset size in percentage"
  type        = number
  default     = 80
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be one of: dev, prod."
  }
}

# --- PrivateLink variables (new) ---
variable "private_link_share_name" {
  description = "Share name for Redis Cloud PrivateLink"
  type        = string
}

variable "private_link_principals" {
  description = "Principals to allow on the PrivateLink"
  type = list(object({
    principal       = string
    principal_type  = string # one of: aws_account, organization, organization_unit, iam_role, iam_user, service_principal
    principal_alias = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for p in var.private_link_principals :
      contains(
        ["aws_account", "organization", "organization_unit", "iam_role", "iam_user", "service_principal"],
        p.principal_type
      )
    ])
    error_message = "Each principal_type must be one of: aws_account, organization, organization_unit, iam_role, iam_user, service_principal."
  }
}


# Choose how to pay for the subscription
# Allowed: "marketplace" or "credit-card"
variable "billing_mode" {
  description = "Subscription billing method"
  type        = string
  default     = "marketplace"
  validation {
    condition     = contains(["marketplace", "credit-card"], var.billing_mode)
    error_message = "billing_mode must be one of: marketplace, credit-card."
  }
}

# For credit-card mode, how to pick the payment method
# Option A: by card_type (e.g., Visa, Mastercard)
variable "card_type" {
  description = "Card type to select when billing_mode = credit-card (e.g., Visa, Mastercard)"
  type        = string
  default     = "Mastercard"
}

# Option B (optional): narrow down to last4 if you have multiple cards of the same type
variable "card_last4" {
  description = "Optional last 4 digits of the desired credit card (used only when billing_mode = credit-card)"
  type        = string
  default     = ""
}

# --- Removed peering flags/IDs (replaced by PrivateLink) ---
# variable "aws_account_id"  (no longer needed)
# variable "aws_vpc_id"      (no longer needed)
# variable "consumer_cidr"   (no longer needed)
# variable "enable_vpc_peering" (no longer needed)