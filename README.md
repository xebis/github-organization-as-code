# GitHub Organization as Code

Streamline GitHub organization repository management with YAML configuration, GitHub workflows, AWS S3 storage, and GitHub App installation—powered by Terraform under the hood.

## Features

Automate GitHub organization repository creation with YAML configuration, powered by Terraform, stored at AWS S3 storage, and configured using GitHub App integration.

### Fun Fact

This GitHub repository was automatically created using the code in this repository.

## Installation and Configuration

Prepare a bucket at AWS S3 or compatible storage.

Create a GitHub App:

- GitHub / *Organization* / Settings / Developer Settings / GitHub Apps / **New GitHub App**
  - Register new GitHub App
    - GitHub App name: *Your GitHub App name*
      - Description: *Your GitHub App description*
    - HomepageURL: *Your GitHub App URL*
  - Webhook
    - Active: unchecked
  - Permissions
    - Repository permissions
      - Administration: Read and write
    - Organization permissions
      - Administration: Read and write
    - Where can this GitHub App be installed?:  
      Only on this account *(for installations only in the current organization)*  
      Any account *(for installations in any organization)*

Install the GitHub App:

- GitHub / *Organization* / Settings / Developer Settings / GitHub Apps / *Your GitHub App name* / Install App
  - **For each** *owner*
    - **Install**
      - for these repositories: All repositories
      - **Install**

Use the GitHub App:

- GitHub / *Organization* / Settings / Developer Settings / GitHub Apps / *Your GitHub App name* / General / Private keys / **Generate a private key**

## Usage

Edit the GitHub organization YAML configuration [`gh-org.yaml`](gh-org.yaml):

```yaml
---
default-properties: # OPTIONAL
  visibility: public # OPTIONAL
  has_issues: true # OPTIONAL
  has_discussions: true # OPTIONAL
  has_projects: true # OPTIONAL
  has_wiki: true # OPTIONAL
repositories:
  - name: repo-slug
    description: Repository description. # OPTIONAL
    visibility: public # OPTIONAL
    has_issues: true # OPTIONAL
    has_discussions: true # OPTIONAL
    has_projects: true # OPTIONAL
    has_wiki: true # OPTIONAL
```

Defaults are the same as in the Terraform provider `github` resource `github_repository`, see [Terraform Registry / Providers / integrations / github / resources / github_repository](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository#argument-reference).

Modify the Terraform backend configuration in [`config.tf`](config.tf) as needed.

Apply the configuration using Terraform:

```shell
export AWS_REGION=<aws-region>
export AWS_ENDPOINT_URL_S3=<aws-endpoint-url-s3> # Only for non-AWS S3 compatible APIs
export AWS_ACCESS_KEY_ID=<aws-access-key-id>
export AWS_SECRET_ACCESS_KEY=<aws-secret-access-key>

export GITHUB_OWNER=<owner>
export GITHUB_APP_ID=<app-id>
export GITHUB_APP_INSTALLATION_ID=<app-installation-id>
export GITHUB_APP_PEM_FILE=$(cat <app-private-key.pem>)

terraform init
terraform plan
terraform apply
```

> [!caution]
> The GitHub App PEM file, S3 API credentials, configuration code, and Terraform state are key security elements.

## Credits and Acknowledgments

- Martin Bružina - Author

## Copyright and Licensing

- MIT License  
  Copyright © 2025 Martin Bružina
