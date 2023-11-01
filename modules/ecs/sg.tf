module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name   = "${var.app_name}-alb-sg"
  vpc_id = var.vpc_id

  ingress_cidr_blocks = local.allowed_cidr

  ingress_rules = [
    "https-443-tcp",
    "http-80-tcp"
  ]

  egress_rules = ["all-all"]
}

module "ecs_service_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name   = "${var.app_name}-app-service-sg"
  vpc_id = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]

  egress_rules = ["all-all"]
}