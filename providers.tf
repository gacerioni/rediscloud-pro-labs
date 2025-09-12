terraform {
  required_providers {
    rediscloud = {
      source = "RedisLabs/rediscloud"
      version = "2.3.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13.0"
    }
  }
}

provider "rediscloud" {
  # Configuration if we lose the VAULT SERVER
  #api_key = var.redis_global_api_key
  #secret_key = var.redis_global_secret_key

  # Config with Vault Server running and with the right expected schema.
  # I am afraid of conventions, but I guess this is the best approach for a DEMO.
  #api_key    = data.vault_generic_secret.redis_secrets.data["global_api_key"]
  #secret_key = data.vault_generic_secret.redis_secrets.data["global_secret_key"]
  api_key = var.redis_global_api_key
  secret_key = var.redis_global_secret_key

}


provider "aws" {
  region     = local.region_for_env
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# USE THIS IF YOU WANT TO USE THE VAULT SECRETS ENGINE
/*
provider "vault" {
  address = var.vault_full_addr
  // Token or other authentication method
  // initial root token bc this is a lab.
  token = var.vault_root_token
}
*/
