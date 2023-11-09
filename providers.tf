terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIATF3QOLZ5IXEBUMPI"
  secret_key = "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"
}