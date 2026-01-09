# Launch Template
# Created from AMI: ami-09198513b0148d8c1
resource "aws_launch_template" "main" {
  name          = "as-config-${var.iam_name}"
  image_id      = var.webserver_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.webserver.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "asg-instance-${var.iam_name}"
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              systemctl start nginx
              systemctl start php-fpm
              EOF
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = "as-group-${var.iam_name}"
  vpc_zone_identifier = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]
  target_group_arns   = [aws_lb_target_group.main.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 0
  max_size         = 3
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-instance-${var.iam_name}"
    propagate_at_launch = true
  }
}

# Scheduled Scaling Action
resource "aws_autoscaling_schedule" "scale_up" {
  scheduled_action_name  = "scale-up-${var.iam_name}"
  min_size               = 0
  max_size               = 3
  desired_capacity       = 2
  recurrence             = "* * * * *"  # Every minute (for testing)
  autoscaling_group_name = aws_autoscaling_group.main.name
  time_zone              = "Asia/Singapore"
}
