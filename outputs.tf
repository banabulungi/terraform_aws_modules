output "vpc_id" {
  description = "ID of the created VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.networking.public_subnet_id

}
output "s3_bucket_name" {
  description = "Name of the created S3 bucket."
  value       = module.s3_bucket.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the created S3 bucket."
  value       = module.s3_bucket.bucket_arn

}