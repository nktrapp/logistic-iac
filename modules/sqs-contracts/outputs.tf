output "queue_names" {
  description = "Main queue names by contract."
  value       = { for key, queue in aws_sqs_queue.main : key => queue.name }
}

output "queue_urls" {
  description = "Main queue URLs by contract."
  value       = { for key, queue in aws_sqs_queue.main : key => queue.url }
}

output "queue_arns" {
  description = "Main queue ARNs by contract."
  value       = { for key, queue in aws_sqs_queue.main : key => queue.arn }
}

output "dlq_names" {
  description = "DLQ names by contract."
  value       = { for key, queue in aws_sqs_queue.dlq : key => queue.name }
}

output "ssm_parameter_names" {
  description = "Published SSM parameter names."
  value       = { for key, param in aws_ssm_parameter.contract : key => param.name }
}
