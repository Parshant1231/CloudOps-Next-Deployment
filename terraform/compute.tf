data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Now use it in your EC2
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.private_app_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name = var.key_name

user_data = templatefile("${path.module}/user_data.sh", {
  docker_image = var.docker_image
  s3_bucket    = aws_s3_bucket.static.bucket  # Note: underscore, not space
  aws_region   = var.aws_region
  app_port     = var.app_port  # optional
})
  # Root volume configuration
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
    
    tags = {
      Name = "${var.project_name}-root-volume"
    }
  }

  tags = {
    Name        = "${var.project_name}-server"
    Environment = var.environment
    OS          = "Ubuntu 20.04"
    ManagedBy   = "Terraform"
  }
}

# Attach EBS volume to EC2
resource "aws_volume_attachment" "data_attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.web.id
}