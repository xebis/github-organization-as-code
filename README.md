# GitHub Organization as Code

Streamline GitHub organization repository management with YAML configuration, GitHub workflows, and GitHub App installation—powered by Terraform under the hood.

## Features

Automate GitHub organization repository creation with YAML configuration, powered by Terraform and GitHub App integration.

### Fun Fact

This GitHub repository was automatically created using the code in this repository.

## Installation and Configuration

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
repositories:
  - id: repo-slug
    description: Repository description.
```

Apply the configuration using Terraform:

```shell
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
