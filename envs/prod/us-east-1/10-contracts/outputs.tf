output "queue_names" {
  description = "Queue names by contract."
  value       = module.sqs_contracts.queue_names
}

output "queue_urls" {
  description = "Queue URLs by contract."
  value       = module.sqs_contracts.queue_urls
}

output "queue_arns" {
  description = "Queue ARNs by contract."
  value       = module.sqs_contracts.queue_arns
}
