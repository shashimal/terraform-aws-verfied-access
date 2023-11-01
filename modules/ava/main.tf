resource "aws_verifiedaccess_trust_provider" "provider" {
  description              = "${var.app_name} trust provider"
  policy_reference_name    = var.policy_reference_name
  trust_provider_type      = "user"
  user_trust_provider_type = "iam-identity-center"
  tags = {
    Name = "IAM"
  }
}

resource "aws_verifiedaccess_instance" "instance" {
  description = "${var.app_name} instance"
  tags = {
    Name = var.app_name
  }
}

resource "aws_verifiedaccess_group" "group" {
  verifiedaccess_instance_id = aws_verifiedaccess_instance.instance.id
  policy_document            = <<EOT
      permit(principal, action, resource)
      when {
      context.IAM.user.email.address like "*@gmail.com"
      };
    EOT
  tags = {
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

resource "awscc_ec2_verified_access_endpoint" "access_endpoint" {
  description = "${var.app_name} access endpoint"

  verified_access_group_id = aws_verifiedaccess_group.group.id

  application_domain     = var.application_domain
  domain_certificate_arn = var.domain_certificate_arn

  attachment_type        = "vpc"
  endpoint_domain_prefix = var.endpoint_domain_prefix
  endpoint_type          = "load-balancer"
  security_group_ids     = var.security_group_ids

  load_balancer_options = {
    load_balancer_arn = var.load_balancer_arn
    port              = var.load_balancer_listener_port
    protocol          = var.load_balancer_listener_protocol
    subnet_ids        = var.subnet_ids
  }

  tags = [
    {
      key   = "Name"
      value = var.app_name
    }

  ]

  depends_on = [
    aws_verifiedaccess_group.group
  ]
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
      records = [awscc_ec2_verified_access_endpoint.access_endpoint.endpoint_domain]
    }
  ]
}