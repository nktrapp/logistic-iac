output "alb_arn" {
  description = "ALB ARN."
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "ALB DNS name."
  value       = aws_lb.main.dns_name
}

output "alb_security_group_id" {
  description = "ALB security group id."
  value       = module.sg.security_group_id
}

output "http_listener_arn" {
  description = "HTTP listener ARN."
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN, empty when HTTPS is disabled."
  value       = local.https_enabled ? aws_lb_listener.https[0].arn : ""
}

output "active_listener_arn" {
  description = "Listener service stacks should attach rules to."
  value       = local.https_enabled ? aws_lb_listener.https[0].arn : aws_lb_listener.http.arn
}
