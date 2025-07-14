resource "aws_launch_template" "app_lt" {
  name          = "${var.project_name}-tpl"
  image_id      = var.ami_id               # AMI ID for your EC2 instances
  instance_type = var.instance_type        # Instance type like "t3.micro"
  key_name      = var.key_pair             # The SSH key pair

  vpc_security_group_ids = [var.app_sg_id]  # Security Group for EC2 instances



  user_data = base64encode(templatefile("../modules/asg/user_data.sh.tpl", {
    db_host = var.db_host
    db_user = var.db_user
    db_pass = var.db_pass
    db_name = var.db_name
  }))
  iam_instance_profile {
    name = var.iam_ssm   
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "App-Instance"
    }
  }

}


resource "aws_autoscaling_group" "app_asg" {
  name                      = "my-app-asg"
  vpc_zone_identifier = [var.private_subnet_app1,var.private_subnet_app2]
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true  # Deletes ASG even if it has instances running

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = aws_launch_template.app_lt.latest_version 
  }

  

 enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  target_group_arns = [var.tg_arn]  # attach instances to ALB target group

  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }
}


resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_description = "Alarm when CPU exceeds 70%"
  alarm_actions     = [aws_autoscaling_policy.scale_out_policy.arn]
}


resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "scale-out"
  autoscaling_group_name  = aws_autoscaling_group.app_asg.name
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
}

# scale down policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" # decreasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5" # Instance will scale down when CPU utilization is lower than 5 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.app_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down.arn]
}
