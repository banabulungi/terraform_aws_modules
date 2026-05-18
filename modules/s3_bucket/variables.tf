variable "bucket_name" {
  description = "Globally Unique S3 bucket name."
  type        = string
}

variable "project_name" {
  description = "Project name used for naming AWS resources."
  type        = string
}

variable "environment" {
  description = "Environment name used for naming AWS resources."
  type        = string
}
