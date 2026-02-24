variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"  # Mumbai region
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "elegant-events"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
  default     = "ami-0f5ee92e2d63afc18"  # Amazon Linux 2023 in ap-south-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ebs_volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 10
}

variable "docker_image" {
  description = "Docker image to run"
  type        = string
  default     = "kanvit279/cloudops-next-deployment:v2"
}

variable "key_name" {
  type    = string
  default = "ubuntu"
}

variable "app_port" {
  description = "Port your Node.js app listens on inside the container"
  type        = number
  default     = 3000
}

output "website_url" {
  value = aws_lb.app_lb.dns_name
}