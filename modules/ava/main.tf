resource "aws_verifiedaccess_trust_provider" "provider" {
  description              = "${var.app_name} trust provider"
  policy_reference_name    = var.policy_reference_name
  trust_provider_type      = "user"
  user_trust_provider_type = "iam-identity-center"
  tags                     = {
    Name = "IAM"
  }
}

resource "aws_verifiedaccess_instance" "instance" {
  description = "${var.app_name} instance"
  tags        = {
    Name = var.app_name
  }
}

resource "aws_verifiedaccess_group" "group" {
  verifiedaccess_instance_id = aws_verifiedaccess_instance.instance.id
  policy_document            = var.policy_document
  tags                       = {
    Name = var.app_name
  }

  depends_on = [
    aws_verifiedaccess_instance_trust_provider_attachment.attachment
  ]
}

resource "aws_verifiedaccess_instance_trust_provider_attachment" "attachment" {
  verifiedaccess_instance_id       = aws_verifiedaccess_instance.instance.id
  verifiedaccess_trust_provider_id = aws_verifiedaccess_trust_provider.provider.id
}

resource "aws_verifiedaccess_endpoint" "access_endpoint" {
  description            = "${var.app_name} access endpoint"
  application_domain     = var.application_domain

  verified_access_group_id = aws_verifiedaccess_group.group.id

  attachment_type        = "vpc"
  domain_certificate_arn = var.domain_certificate_arn
  endpoint_domain_prefix = var.endpoint_domain_prefix
  endpoint_type          = "load-balancer"

  load_balancer_options {
    load_balancer_arn = var.load_balancer_arn
    port              = var.load_balancer_listener_port
    protocol          = var.load_balancer_listener_protocol
    subnet_ids        = var.subnet_ids
  }

  security_group_ids       = var.security_group_ids

  tags = {
    Name = var.app_name
  }
}

module "route53_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_id = var.zone_id

  records = [
    {
      name    = "app"
      type    = "CNAME"
      ttl     = 5
      records = [aws_verifiedaccess_endpoint.access_endpoint]
    }
  ]
}