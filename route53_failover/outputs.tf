output "sns_topic_arn" {
  description = "SNS topic ARN used for health alerts"
  value       = aws_sns_topic.alerts.arn
}

output "route53_health_check_id" {
  description = "ID of the Route53 health check for primary"
  value       = aws_route53_health_check.primary.id
}

output "primary_record" {
  description = "Primary Route53 A record"
  value       = aws_route53_record.primary.fqdn
}

output "secondary_record" {
  description = "Secondary Route53 A record"
  value       = aws_route53_record.secondary.fqdn
}
