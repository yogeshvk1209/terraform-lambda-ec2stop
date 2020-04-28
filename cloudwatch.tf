resource "aws_cloudwatch_event_rule" "ec2stop-rule" {
    name = "ec2stop-rule"
    description = "Fires every Ten minutes"
    schedule_expression = "rate(10 minutes)"
}

resource "aws_cloudwatch_event_target" "ec2stop-rule-target" {
    rule = aws_cloudwatch_event_rule.ec2stop-rule.name
    arn = aws_lambda_function.lambda.arn
}
