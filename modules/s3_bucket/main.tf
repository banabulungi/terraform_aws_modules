resource "aws_s3_bucket" "s3_bucket_name_biniyam" {
  bucket = var.bucket_name

  tags = {
    Name = "${var.project_name}-${var.environment}-bucket"

  }
}

resource "aws_s3_bucket_versioning" "s3_bucket_version_1" {
  bucket = aws_s3_bucket.s3_bucket_name_biniyam.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encryption_1" {
  bucket = aws_s3_bucket.s3_bucket_name_biniyam.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_1" {
  bucket = aws_s3_bucket.s3_bucket_name_biniyam.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}