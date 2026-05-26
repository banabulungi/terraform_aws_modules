variable "aws_region" {
  description = "AWS region to use for provider"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "mom-and-pop"
}

variable "environment" {
  description = "Environment name (dev/stage/prod)"
  type        = string
  default     = "dev"
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID where DNS records will be created"
  type        = string
}

variable "domain_name" {
  description = "The DNS name to configure failover for (e.g. www.example.com)"
  type        = string
}

variable "primary_ip" {
  description = "Public IP address of the primary web server (primary AZ)"
  type        = string
}

variable "secondary_ip" {
  description = "Public IP address of the secondary web server (secondary AZ)"
  type        = string
}

variable "health_check_path" {
  description = "HTTP path used by the Route53 health check"
  type        = string
  default     = "/"
}

variable "alert_email" {
  description = "Email address to receive SNS notifications when primary becomes unhealthy"
  type        = string
}
