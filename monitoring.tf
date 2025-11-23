####### SNS Topic for CPU Alerts #######
resource "aws_sns_topic" "cpu_alert_topic" {
  name = "user-updates-topic"
}

####### SNS Topic Subscription for Email #######
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cpu_alert_topic.arn
  protocol  = "email"
  endpoint  = "amrmedhatamer100@gmail.com"
}


######## CloudWatch Metric Alarm for Frontend EC2 CPU Utilization ########

resource "aws_cloudwatch_metric_alarm" "frontend_cpu_alarm" {

  alarm_name          = "frontend-cpu-high-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50" 
  alarm_description   = "Alarm when CPU exceeds 50%"
  actions_enabled     = true

  alarm_actions = [aws_sns_topic.cpu_alert_topic.arn]

  dimensions = {
    InstanceId = aws_instance.EC2-Frontend.id
  }
}


##### CloudWatch Metric Alarm for Backend EC2 CPU Utilization ########
resource "aws_cloudwatch_metric_alarm" "Backend_cpu_alarm" {

  alarm_name          = "Backend-cpu-high-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50" 
  alarm_description   = "Alarm when CPU exceeds 50%"
  actions_enabled     = true

  alarm_actions = [aws_sns_topic.cpu_alert_topic.arn]

  dimensions = {
    InstanceId = aws_instance.EC2-Backend.id    
  }
}
