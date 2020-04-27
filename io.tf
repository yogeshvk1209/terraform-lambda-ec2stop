### Variables
variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-west-2"
}

### Outputs
output "lambda" {
  value = "${aws_lambda_function.lambda.qualified_arn}"
}
