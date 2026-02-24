# Create EBS Volume
resource "aws_ebs_volume" "data" {
  availability_zone = "${var.aws_region}a"
  size              = var.ebs_volume_size
  type              = "gp3"

  tags = {
    Name        = "${var.project_name}-data-volume"
    Environment = var.environment
  }
}

# Create S3 Bucket
resource "aws_s3_bucket" "static" {
  bucket = "kanvit279-cloudops-next-deployment"  # Use hyphens, not slashes!

  tags = {
    Name        = "kanvit279-cloudops-next-deployment"
    Environment = var.environment
  }
}

# Random suffix for bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "static" {
  bucket = aws_s3_bucket.static.id
  versioning_configuration {
    status = "Enabled"
  }
}

