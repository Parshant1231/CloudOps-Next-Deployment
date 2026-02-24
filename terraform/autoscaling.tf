resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project_name}-lt"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    docker_image = var.docker_image
    s3_bucket    = aws_s3_bucket.static.bucket
    app_port     = var.app_port
  }))

  vpc_security_group_ids = [aws_security_group.private_app_sg.id]
}

resource "aws_autoscaling_group" "app_asg" {
  min_size         = 2
  max_size         = 3
  desired_capacity = 2

  vpc_zone_identifier = [
    aws_subnet.private.id,
    aws_subnet.private_2.id
  ]

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}