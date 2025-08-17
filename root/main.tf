module "vpc" {
  source            = "../modules/vpc"
  project_name      = var.project_name
  vpc_cidr          = var.vpc_cidr
  pub_sub_1a_cidr   = "10.0.1.0/24"
  pub_sub_1b_cidr   = var.pub_sub_1b_cidr
  priv_sub_2a_cidr  = var.priv_sub_2a_cidr
  priv_sub_2b_cidr  = var.priv_sub_2b_cidr
  priv_sub_3a_cidr  = var.priv_sub_3a_cidr
  priv_sub_3b_cidr  = var.priv_sub_3b_cidr
}

module "nat" {
  source = "../modules/nat"
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids    = module.vpc.public_subnet_ids
  igw_id              = module.vpc.igw_id
  vpc_id              = module.vpc.vpc_id
  app_subnet_1a_id    = module.vpc.app_subnet_1a_id
  app_subnet_1b_id    = module.vpc.app_subnet_1b_id
  db_subnet_1a_id     = module.vpc.db_subnet_1a_id
  db_subnet_1b_id     = module.vpc.db_subnet_1b_id
  project_name        = var.project_name
}

module "security-group" {
  source = "../modules/security-group"
  vpc_id = module.vpc.vpc_id
}

# creating Key for instances
module "key" {
  source = "../modules/key"
}

# creating RDS instance
module "rds" {
  source         =  "../modules/rds"
  project_name = var.project_name
  db_sg_id       =  module.security-group.db_sg_id
  db_subnet_1a_id = module.vpc.db_subnet_1a_id
  db_subnet_1b_id = module.vpc.db_subnet_1b_id
  db_username    = var.db_username
  db_password    = var.db_password
  db_subnet_group_name  = var.db_subnet_group_name
  db_name = var.db_name
}


# Creating Application Load balancer
module "alb" {
  source         = "../modules/alb"
  project_name   = var.project_name
  alb_sg_id      = module.security-group.alb_sg_id
  public_subnet_1a_id = module.vpc.public_subnet_1a_id
  public_subnet_1b_id = module.vpc.public_subnet_1b_id
  vpc_id         = module.vpc.vpc_id
}



module "asg" {
  source               = "../modules/asg"
  project_name         = var.project_name
  db_host = module.rds.db_endpoint
  db_user = module.rds.db_username
  db_pass = module.rds.db_password
  db_name = module.rds.db_name
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  app_sg_id            = module.security-group.app_sg_id
  key_pair             = module.key.key_name
  max_size             = var.auto_scale_max_size
  min_size             = var.auto_scale_min_size
  desired_capacity     = var.auto_scale_desired_capacity
  private_subnet_app1  = module.vpc.app_subnet_1a_id
  private_subnet_app2  = module.vpc.app_subnet_1b_id
  tg_arn               = module.alb.tgt_arn
   iam_ssm = var.iam_ssm
}



# Add record in route 53 hosted zone
module "route53" {
  source = "../modules/route53"
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id = module.alb.alb_zone_id
  s3_website_endpoint = var.s3_website_endpoint
  s3_website_zone_id = var.s3_website_zone_id
  domain_name = var.domain_name

}


module "lambda_function"  {
   source        = "../modules/lambda_function"
  function_name = "my-scheduled-lambda"
  handler       = "index.handler"
  runtime = "python3.12"
}

module "morning_eventbridge_scheduler" {
  source                 = "../modules/eventbridge_scheduler"
  name = "morning-scheduler"
  schedule_expression    = var.morning_schedule_expression
  lambda_function_name   = module.lambda_function.function_name
  lambda_function_arn    = module.lambda_function.arn
  action =var.morning_action
  role_name              = "scheduler-invoke-lambda-role-morning"

}

module "evening_eventbridge_scheduler" {
  source                 = "../modules/eventbridge_scheduler"
  name = "evening-scheduler"
  schedule_expression    = var.evening_schedule_expression
  action = var.evening_action
  lambda_function_name   = module.lambda_function.function_name
  lambda_function_arn    = module.lambda_function.arn
  role_name              = "scheduler-invoke-lambda-role-evening"
}
















