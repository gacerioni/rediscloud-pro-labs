terraform {
  required_providers {
    rediscloud = {
      source  = "RedisLabs/rediscloud"
      version = "~> 2.10.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13.0"
    }
  }
}

provider "rediscloud" {
  api_key    = var.redis_global_api_key
  secret_key = var.redis_global_secret_key
}

# Optional: keep if you’ll also manage the AWS consumer interface endpoint in this workspace.
# (Not required for creating the Redis Cloud PrivateLink share.)
provider "aws" {
  region     = local.region_for_env
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}