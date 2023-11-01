variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type    = list(string)
  default = []
}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "allowed_cidr" {
  type    = list(string)
  default = []
}

variable "environment_list" {
  type    = any
  default = []
}

variable "acm_certificate" {
  type = string
}