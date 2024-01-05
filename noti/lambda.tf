module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "AWS-TO-SLACK"
  description   = "AWS to slack Noti"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  
source_path = "./src/lambda-function"
  environment_variables = {
    HOOK_URL = "https://hooks.slack.com/services/T04BD2YD327/B04BLNBA4MT/"
    SLACK_CHANNEL = "test"
  }

  tags = {
    Name = "PRD"
   }
}


