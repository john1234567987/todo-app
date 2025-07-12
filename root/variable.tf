variable "project_name" {
  description = "Project name for the VPC"
  type        = string
}

variable "region" {
  description = "This is a two tier application for php"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "pub_sub_1a_cidr" {
  description = "CIDR block for public subnet 1a"
  type        = string
}

variable "pub_sub_1b_cidr" {
  description = "CIDR block for public subnet 1b"
  type        = string
}

variable "priv_sub_2a_cidr" {
  description = "CIDR block for private subnet 2a"
  type        = string
}

variable "priv_sub_2b_cidr" {
  description = "CIDR block for private subnet 2b"
  type        = string
}

variable "priv_sub_3a_cidr" {
  description = "CIDR block for private subnet 3a"
  type        = string
}

variable "priv_sub_3b_cidr" {
  description = "CIDR block for private subnet 3b"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}


variable "auto_scale_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
}

variable "auto_scale_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
}

variable "auto_scale_desired_capacity" {
  description = "Desired number of instances to run in the Auto Scaling Group"
  type        = number
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "db_subnet_group_name" {
  description = "Name of the RDS subnet group spanning subnets in AZ-a and AZ-b"
  type        = string
}


variable "db_name" {
  description = "Name of the initial database to create within the RDS instance."
  type        = string
}

variable "s3_website_endpoint" {
  description = "The DNS endpoint of the static website hosted on S3"
  type        = string
}

variable "s3_website_zone_id" {
  description = "The Route 53 hosted zone ID for the S3 website endpoint (region-specific)"
  type        = string
  default     = "Z3GKZC51ZF0DB4"  # eu-west-2 — you can override if needed
}

variable "domain_name" {
  description = "The domain name for the application and ACM certificate"
  type        = string
}

variable "iam_ssm" {
    description = "This is an IAM plicy that allow user to upload a file from s3 bucket"
    type        = string
}

variable "morning_schedule_expression" {
  description = "CloudWatch cron expression to trigger scaling up"
  type        = string
}

variable "evening_schedule_expression" {
  description = "CloudWatch cron expression to trigger scaling down"
  type        = string
}

variable "morning_action" {
  description = "Action to perform in the morning"
  type        = string
}

variable "evening_action" {
  description = "Action to perform in the evening"
  type        = string
}

