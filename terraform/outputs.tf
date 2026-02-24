
output "ssh_command" {
  description = "SSH command to connect to EC2"
  value       = "ssh -i ubuntu.pem ubuntu@${aws_instance.web.public_ip}"
}

output "s3_backup_bucket" {
  description = "S3 bucket for backups"
  value       = aws_s3_bucket.static.bucket
}

output "docker_image" {
  description = "Docker image being used"
  value       = var.docker_image
}


# Outputs
output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.web.public_dns
}

output "s3_bucket_name" {
  value = aws_s3_bucket.static.bucket
}