resource "aws_cloudwatch_metric_alarm" "cpu-high" {
  alarm_name                = "${var.environment}-cpu-high"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120 # 2 minutes
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization if too high"
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu-low" {
  alarm_name                = "${var.environment}-cpu-low"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120 # 2 minutes
  statistic                 = "Average"
  threshold                 = 30
  alarm_description         = "This metric monitors ec2 cpu utilization if too low"
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
}

