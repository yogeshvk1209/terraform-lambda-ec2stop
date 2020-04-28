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
    actions = ["ec2:*"]
    resources = ["*"]
  }
  statement {
    sid    = ""
    effect = "Allow"
    actions = ["logs:*"]
    resources = ["*"]
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
