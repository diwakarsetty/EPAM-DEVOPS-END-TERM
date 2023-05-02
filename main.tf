provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_function" "mass_emailer" {
  filename      = "lambda_function.zip"
  function_name = "mass_emailer"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  memory_size   = 128
  timeout       = 10

  environment {
    variables = {
      SOURCE_EMAIL = "diwakarsetty79@gmail.com"
    }
  }
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "mass-emailer-lambda-bucket"
}

resource "aws_s3_object" "lambda_object" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "lambda_function.zip"
  source = "lambda_function.zip"
}

resource "aws_cloudwatch_event_rule" "mass_emailer_schedule" {
  name                = "mass_emailer_schedule"
  schedule_expression = "cron(0 12 * * ? *)" # send emails every day at noon

  depends_on = [
    aws_lambda_function.mass_emailer,
  ]
}

resource "aws_cloudwatch_event_target" "mass_emailer_target" {
  rule = aws_cloudwatch_event_rule.mass_emailer_schedule.name
  arn  = aws_lambda_function.mass_emailer.arn
}
