# GitHub Organization as Code

Manage your GitHub organization repositories with GitOps principles using YAML configuration, GitHub Actions, AWS S3 storage, and GitHub App integration—powered by Terraform.

## Features

- **Automated Repository Management** - Define repositories, and repository properties using simple YAML file.
- **GitOps Workflow** - Manage configurations via pull requests and automate updates using GitHub Actions.
- **Terraform** - Uses Terraform under the hood to apply changes efficiently.
- **Terraform State Management** - Stores Terraform state securely in AWS S3.
- **GitHub App Integration** - Uses a GitHub App for authentication and API interactions.

### Fun Fact

This repository was automatically created and is continuously managed using the very code inside it!

## Installation and Configuration

Set up an AWS S3 bucket or a compatible storage service.

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

Get the GitHub App credentials:

- GitHub / *Organization* / Settings / Developer Settings / GitHub Apps / *Your GitHub App name* / General / Private keys / **Generate a private key**

Set up GitHub actions, variables and secrets:

- GitHub / *Repository* / Settings
  - Actions / General
    - Workflow permissions: Read and write permissions
  - Secrets and variables / Actions / Actions secrets and variables
    - Secrets
      - **New repository secret**
        - `APP_PEM_FILE` (`GITHUB_APP_PEM_FILE` contents)
        - `AWS_ACCESS_KEY_ID`
        - `AWS_SECRET_ACCESS_KEY`
    - Variables
      - **New repository variable**
        - `APP_ID` (`GITHUB_APP_ID`)
        - `APP_INSTALLATION_ID` (`GITHUB_APP_INSTALLATION_ID`)
        - `AWS_ENDPOINT_URL_S3`
        - `AWS_REGION`
        - `OWNER` (`GITHUB_OWNER`)

> [!caution]
> The GitHub App PEM file, S3 API credentials, Terraform state, GitHub repository secrets, and configuration code are key security elements.

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
    topics: # OPTIONAL
      - github-topic-1
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

## Credits and Acknowledgments

- Martin Bružina - Author

## Copyright and Licensing

- MIT License  
  Copyright © 2025 Martin Bružina
