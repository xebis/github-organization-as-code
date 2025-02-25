terraform {
  required_version = ">= 0.13"
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.0.0"
    }
  }
}

provider "github" {
  app_auth {}
}
