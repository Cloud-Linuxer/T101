resource "aws_sns_topic" "ec2_updates" {
  name = "user-updates-topic"
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.ec2_updates.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
  depends_on = [module.lambda_function.this]
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
resource "aws_sns_topic_subscription" "ec2_updates_target" {
  topic_arn = aws_sns_topic.ec2_updates.arn
  protocol  = "lambda"
  endpoint  = module.lambda_function.lambda_function_arn
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.ec2_updates.arn
}
