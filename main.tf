module "vpc" {
  source = "./modules/vpc"

  env                = local.env
  name               = local.app_name
  azs                = local.azs
  cidr               = local.cidr
  private_subnets    = local.private_subnets
  public_subnets     = local.public_subnets
  database_subnets   = local.database_subnets
  enable_nat_gateway = true
  single_nat_gateway = true
}

module "ecs" {
  source = "./modules/ecs"

  app_name         = local.app_name
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnets
  public_subnets   = module.vpc.public_subnets
  environment_list = []
  acm_certificate  = module.acm.acm_certificate_arn
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "sms.duleendra.com"
  zone_id     = "<your zone id>"

  validation_method = "DNS"

  subject_alternative_names = [
    "*.sms.duleendra.com"
  ]

  wait_for_validation = true
}

module "aws_verified_access" {
  source = "./modules/ava"

  app_name = local.app_name
  zone_id  = "<your zone id>"

  application_domain     = "app.sms.duleendra.com"
  domain_certificate_arn = module.acm.acm_certificate_arn
  endpoint_domain_prefix = "appsms"
  policy_reference_name  = "IAM"

  load_balancer_arn               = module.ecs.alb_id
  load_balancer_listener_port     = 80
  load_balancer_listener_protocol = "http"
  subnet_ids                      = module.vpc.private_subnets
  security_group_ids              = [module.verified_access_sg.security_group_id]

  policy_document = <<EOT
  permit(principal, action, resource)
  when {
    context.http_request.http_method != "INVALID_METHOD"
  };
EOT
}

module "verified_access_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name   = "${local.app_name}-verified-access-sg"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_rules = [
    "https-443-tcp",
    "http-80-tcp"
  ]

  egress_rules = ["all-all"]
}