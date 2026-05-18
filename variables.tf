variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name used for naming AWS resources."
  type        = string
  default     = "terraform-learning"
}
variable "environment" {
  description = "Environment name used for naming AWS resources."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.10.0.0/16"

}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.10.1.0/24"
}

variable "s3_bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

