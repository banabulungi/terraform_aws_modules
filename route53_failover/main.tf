locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# SNS topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${local.name_prefix}-route53-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Route53 health check for primary web server (by IP)
resource "aws_route53_health_check" "primary" {
  ip_address     = var.primary_ip
  port           = 80
  type           = "HTTP"
  resource_path  = var.health_check_path
  request_interval = 30
  failure_threshold = 3
  tags = {
    Name = "${local.name_prefix}-primary-hc"
  }
}

# CloudWatch alarm on the Route53 health check to send SNS notifications
resource "aws_cloudwatch_metric_alarm" "primary_unhealthy" {
  alarm_name          = "${local.name_prefix}-route53-primary-unhealthy"
  alarm_description   = "Triggered when the Route53 health check for primary is unhealthy"
  namespace           = "AWS/Route53"
  metric_name         = "HealthCheckStatus"
  dimensions = {
    HealthCheckId = aws_route53_health_check.primary.id
  }
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

# Primary DNS record (failover = PRIMARY)
resource "aws_route53_record" "primary" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 60
  records = [var.primary_ip]
  set_identifier  = "primary"
  health_check_id = aws_route53_health_check.primary.id

  failover_routing_policy {
    type = "PRIMARY"
  }
}

# Secondary DNS record (failover = SECONDARY)
resource "aws_route53_record" "secondary" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 60
  records = [var.secondary_ip]
  set_identifier = "secondary"

  failover_routing_policy {
    type = "SECONDARY"
  }
}
