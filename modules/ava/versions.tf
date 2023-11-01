terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "0.63.0"
    }
  }
}

provider "awscc" {
  region = "us-east-1"
}