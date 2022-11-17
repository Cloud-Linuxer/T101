module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "AWS-TO-CLACK"
  description   = "AWS to slack Noti"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  source_path = "./src/lambda-function"
  environment_variables = {
    HOOK_URL = ""
    SLACK_CHANNEL = ""
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

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.ec2_updates.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish"
    ]
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.ec2_updates.arn,
    ]

    sid = "__default_statement_ID"
  }
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
