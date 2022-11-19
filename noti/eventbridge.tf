module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"
  create_bus = false
  rules = {
    orders = {
      description   = "Capture all order data"
      event_pattern = jsonencode({
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "ec2.amazonaws.com"
    ],
    "eventName": [
      "AuthorizeSecurityGroupIngress",
      "AuthorizeSecurityGroupEgress",
      "RevokeSecurityGroupIngress",
      "RevokeSecurityGroupEgress"
    ]
  }
})
      enabled       = true
    }
  }

  targets = {
    orders = [
      {
        name = "log-orders-to-cloudwatch"
        arn  = aws_sns_topic.ec2_updates.arn
      }
    ]
  }
}
