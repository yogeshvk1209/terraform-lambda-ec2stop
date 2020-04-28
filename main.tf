# Specify the provider and access details
provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "terra-buck2"
    key    = "terra-lambda-state"
    region = "us-west-2"
    profile = "default"
  }
}

provider "archive" {}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

## Lambda Function ##
resource "aws_lambda_function" "lambda" {
  function_name = "ec2stop"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_sha
  role    = aws_iam_role.iam_for_lambda.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.6"
  timeout = "30"
}
