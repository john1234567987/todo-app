
variable "name" {
  description = "Name of the Scheduler"
  type        = string
}

variable "schedule_expression" {
  description = "Schedule expression (cron or rate)"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role to allow EventBridge Scheduler to invoke Lambda"
  type        = string
}


variable "lambda_function_arn" {
  description = "ARN of the Lambda function"
  type        = string
}
variable "action" {
  description = "The scaling action to perform, e.g. scale_up or scale_down"
  type        = string
}


