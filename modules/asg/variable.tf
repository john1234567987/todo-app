variable "project_name"{}
variable "ami_id" {
  description = "AMI ID for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}
variable "app_sg_id" {
  description = "Security Group ID to associate with the application EC2 instances"
  type        = string
}

variable "key_pair" {
  description = "The name of the EC2 key pair to use for SSH access"
  type        = string
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances to run in the Auto Scaling Group"
  type        = number
}

variable "private_subnet_app1" {
  description = "ID of the private subnet for application tier in AZ 1"
  type        = string
}

variable "private_subnet_app2" {
  description = "ID of the private subnet for application tier in AZ 2"
  type        = string
}

variable "tg_arn" {
  description = "ARN of the target group"
  type        = string
}

variable "iam_ssm" {
    description = "This is an IAM plicy that allow user to upload a file from s3 bucket"
    type        = string
}

variable "db_host" {
  description = "The database endpoint"
  type        = string
}

variable "db_user" {
  description = "The database username"
  type        = string
}

variable "db_pass" {
  description = "The database password"
  type        = string
}

variable "db_name" {
  description = "The database name"
  type        = string
}
