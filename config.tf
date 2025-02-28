terraform {
  required_version = ">= 0.13"
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.0.0"
    }
  }

  backend "s3" {
    bucket       = "xebis-terraform"
    key          = "github-xebis"
    use_lockfile = true # Set to false only for non-AWS S3 compatible APIs without "conditional object PUTs" capability

    # Only for non-AWS S3 compatible APIs
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "github" {
  app_auth {}
}
