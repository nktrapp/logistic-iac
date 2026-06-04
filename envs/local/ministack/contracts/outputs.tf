output "queue_names" {
  description = "MiniStack queue names."
  value       = module.sqs_contracts.queue_names
}

output "queue_urls" {
  description = "MiniStack queue URLs."
  value       = module.sqs_contracts.queue_urls
}

output "ssm_parameter_names" {
  description = "Published local SSM parameters."
  value       = module.sqs_contracts.ssm_parameter_names
}
