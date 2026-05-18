output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.vpc_bini.id

}

output "public_subnet_id" {
  description = "Public Subnet ID."
  value       = aws_subnet.public_subnet_bini.id

}

output "security_group_id" {
  description = "Security Group ID."
  value       = aws_security_group.public_sg.id

}
