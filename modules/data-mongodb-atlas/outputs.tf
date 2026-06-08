output "srv_address" {
  description = "Standard SRV address without credentials (mongodb+srv://...)."
  value       = mongodbatlas_advanced_cluster.this.connection_strings.standard_srv
}

output "connection_uri" {
  description = "Full SRV connection string with credentials and default database."
  value = format(
    "mongodb+srv://%s:%s@%s/%s?retryWrites=true&w=majority",
    var.db_username,
    local.db_password,
    replace(mongodbatlas_advanced_cluster.this.connection_strings.standard_srv, "mongodb+srv://", ""),
    var.database_name,
  )
  sensitive = true
}

output "project_id" {
  description = "Atlas project id."
  value       = mongodbatlas_project.this.id
}
