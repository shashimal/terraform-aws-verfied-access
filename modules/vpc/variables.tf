variable "name" {
  type        = string
  description = "VPC name"
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets"
}

variable "database_subnets" {
  type        = list(string)
  description = "Database subnets"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable Nat Gateway"
}

variable "single_nat_gateway" {
  type        = bool
  description = "Single Nat Gateway "
}
