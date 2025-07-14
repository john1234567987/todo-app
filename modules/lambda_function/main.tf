resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}-lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  filename = "${path.module}/lambda_function.zip"
  role          = aws_iam_role.lambda_exec.arn
}

