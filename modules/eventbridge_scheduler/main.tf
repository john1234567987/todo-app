resource "aws_iam_role" "scheduler_invoke_lambda_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "scheduler.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_scheduler_schedule" "lambda_target" {
  name                = var.name
  schedule_expression = var.schedule_expression


  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = var.lambda_function_arn
    role_arn = aws_iam_role.scheduler_invoke_lambda_role.arn

    input = jsonencode({
      action = var.action
    })
  }
}

resource "aws_iam_role_policy" "invoke_lambda_policy" {
  name = var.role_name
  role = aws_iam_role.scheduler_invoke_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "lambda:InvokeFunction",
      Resource = var.lambda_function_arn
    }]
  })
}

