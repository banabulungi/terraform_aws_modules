# Route53 Failover Routing (Mom & Pop Café)

This Terraform project configures Amazon Route 53 failover routing for a website with two existing EC2 web servers (primary and secondary in different Availability Zones). It creates:

- a Route 53 HTTP health check that probes the primary server
- a CloudWatch alarm on the Route 53 health metric that notifies an SNS topic
- an SNS topic subscription that sends an email alert when the primary becomes unhealthy
- two Route 53 A records using failover routing (PRIMARY and SECONDARY)

Prerequisites
- An existing Route 53 hosted zone and the hosted zone ID.
- Two running web servers with public IP addresses (primary + secondary) serving HTTP (port 80).
- AWS credentials configured for Terraform (environment or shared config).

Quick start

1. Copy the example variables and edit values:

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars and set hosted_zone_id, domain_name, primary_ip, secondary_ip, alert_email
```

2. Initialize and validate:

```bash
terraform init
terraform validate
```

3. Preview and apply:

```bash
terraform plan
terraform apply
```

Verification

- After `terraform apply`, check `terraform output` to see SNS topic, health check, and records.
- Confirm you receive a subscription confirmation email from SNS; you must click the link to confirm the email subscription.
- Simulate primary failure by stopping the webserver on the primary IP (or returning 500). Route 53 will detect unhealthy and DNS will failover to the secondary.

Notes
- Route 53 health checks are public — the health checks come from AWS IP ranges. Ensure your web server allows access from AWS health check IPs or that the endpoint is reachable publicly.
- SNS email subscriptions require manual confirmation.
- If you prefer to monitor hostnames instead of raw IPs, change `aws_route53_health_check.primary` to use `fqdn` and appropriate `request_interval`/`port` settings.
