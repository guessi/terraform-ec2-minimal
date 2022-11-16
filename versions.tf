terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.39"
    }

    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}
