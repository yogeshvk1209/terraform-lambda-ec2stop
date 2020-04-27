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

## Assume role policy document ##
data "aws_iam_policy_document" "assume_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "sts:AssumeRole",
    ]
  }
}

## Resource access policy document ##
data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = ["*"]
    resources = ["arn:aws:ec2:::*"]
  }
  statement {
    sid    = ""
    effect = "Allow"
    actions = ["*"]
    resources = ["arn:aws:logs:::*"]
  }
}

## Resource access policy creation using above policy ##
resource "aws_iam_policy" "lambda_policy"{
  name   = "lambda_policy"
  policy = data.aws_iam_policy_document.policy.json
}

## IAM role creation ##
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
}

## Attach resourcce policy created earlier ##
resource "aws_iam_role_policy_attachment" "attach-policies" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
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
