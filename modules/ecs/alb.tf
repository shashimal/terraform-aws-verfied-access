module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "alb-${var.app_name}"

  internal           = true
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.private_subnets
  security_groups    = [module.alb_sg.security_group_id]

  target_groups = [
    {
      name             = "tg-alb-${var.app_name}-app"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        enabled             = true
        interval            = 15
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  #    https_listeners = [
  #      {
  #        port               = 443
  #        protocol           = "HTTPS"
  #        certificate_arn    = var.acm_certificate
  #        target_group_index = 0
  #      }
  #    ]
}