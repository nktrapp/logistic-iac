output "host" {
  description = "Redis host (public endpoint without port)."
  value       = local.endpoint_parts[0]
}

output "port" {
  description = "Redis port."
  value       = tonumber(local.endpoint_parts[1])
}

output "password" {
  description = "Redis database password."
  value       = local.database_password
  sensitive   = true
}

output "public_endpoint" {
  description = "Raw host:port endpoint."
  value       = rediscloud_essentials_database.this.public_endpoint
}
