# Changelog

## [2.0.0] - 2026-01-26

### Major Changes
- **Updated to Redis Cloud Provider 2.10.1** - Latest provider version with bug fixes
- **Redis 8.2 Support** - Default version now 8.2 (includes all modules by default)
- **Dual-Mode Configuration** - Single codebase supports both creating new subscriptions and adding databases to existing subscriptions

### Added
- `create_subscription` variable - Controls whether to create new subscription or use existing
- `existing_subscription_id` variable - Specify existing subscription ID
- `redis_version` variable - Configurable Redis version (default: 8.2)
- Conditional resource creation using `count` parameter
- Separate example tfvars files for both modes:
  - `terraform.tfvars.NEW_SUBSCRIPTION.example`
  - `terraform.tfvars.EXISTING_SUBSCRIPTION.example`
- Documentation for using separate state files for multiple databases

### Changed
- Removed `modules` variable - Redis 8+ includes all modules by default
- Made subscription resource conditional based on `create_subscription`
- Made PrivateLink resource conditional (only created with new subscriptions)
- Updated all resource references to use `local.subscription_id`
- Updated outputs to handle conditional resources
- Provider version constraint changed from `>= 2.4.4` to `~> 2.10.1`

### Removed
- Explicit module specification from subscription `creation_plan`
- Explicit module specification from database resource
- `modules` variable (no longer needed for Redis 8+)

### Fixed
- PrivateLink now only created when creating new subscription (subscription-level resource)
- Payment method lookup only runs when creating new subscription
- Outputs properly handle null values for conditional resources

## [1.0.0] - Initial Release

### Features
- Redis Cloud PRO subscription creation
- Database provisioning with Redis 7.4
- AWS PrivateLink connectivity
- RBAC/ACL user management
- Flexible billing (Marketplace or Credit Card)
- Environment-aware region mapping

