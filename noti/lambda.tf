module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "AWS-TO-CLACK"
  description   = "AWS to slack Noti"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  source_path = "./src/lambda-function"
  environment_variables = {
    HOOK_URL = "https://hooks.slack.com/services/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"
    SLACK_CHANNEL = "테스트"
  }

  tags = {
    Name = "PRD"
   }
}


resource "aws_sns_topic" "ec2_updates" {
  name = "user-updates-topic"
}
resource "aws_sns_topic_subscription" "ec2_updates_target" {
  topic_arn = aws_sns_topic.ec2_updates.arn
  protocol  = "lambda"
  endpoint  = module.lambda_function.lambda_function_arn
}

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
