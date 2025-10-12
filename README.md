# GitHub Organization as Code

Manage your GitHub organization's repositories using GitOps principles with a YAML-based configuration, GitHub Actions with reusable workflows, AWS S3 for storage, and GitHub App integration.

## Features

- **Automated Repository Management** - Define repositories, and repository properties using simple YAML file.
- **GitOps Workflow** - Manage configurations via pull requests and automate updates using GitHub Actions.
- **Terraform** - Uses Terraform under the hood to apply changes efficiently.
- **Terraform State Management** - Stores Terraform state securely in AWS S3.
- **GitHub App Integration** - Uses a GitHub App for authentication and API interactions.

### Fun Fact

This repository was automatically created and is continuously managed using the very code inside it!

## Installation and Configuration

- Configure an AWS S3 bucket to store Terraform state files.
- Set up a GitHub App and its installation to handle authentication and authorization for your GitHub Organization.
- Implement GitOps by setting up a GitHub repository with:
  - YAML-based configuration
  - GitHub workflows
  - Repository variables and secrets

> [!caution]
> The GitHub App PEM file, S3 API credentials, Terraform state, GitHub repository secrets, and configuration code are key security elements.

### Set Up AWS S3 Bucket

Set up an AWS S3 bucket or a compatible storage service.

> [!important]
> Ensure you have the following details ready:
>
> - Bucket Name
> - Access Key ID
> - Secret Access Key
> - Region
> - S3 Endpoint URL (only required for non-AWS S3-compatible services)

### Set Up GitHub Organizations

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

> [!important]
> Ensure you have the following details ready:
>
> - GitHub Owner
> - GitHub App ID
> - GitHub App Installation ID
> - GitHub App PEM File

### Set Up GitHub Repository for GitHub Organization Management

Create GitHub organization YAML configuration file. See [GitHub Organization YAML](#github-organization-yaml) below.

For example:

```yaml
---
repositories:
  - name: .github
    description: The organization profile.
    topics:
      - github-organization-profile
      - github-profile
      - github-profile-readme
```

Create GitHub workflow planning and applying configuration changes to the GitHub Organization:

```yaml
---
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  call-terraform:
    uses: xebis/github-organization-as-code/.github/workflows/terraform.yaml@v0
    with:
      aws_region: ${{ vars.AWS_REGION }}
      aws_endpoint_url_s3: ${{ vars.AWS_ENDPOINT_URL_S3 }}
      gh_owner: ${{ vars.GH_OWNER }}
      gh_app_id: ${{ vars.GH_APP_ID }}
      gh_app_installation_id: ${{ vars.GH_APP_INSTALLATION_ID }}
      path: xebis.yaml
    secrets:
      aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
      aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      gh_app_pem_file: ${{ secrets.GH_APP_PEM_FILE }}
```

Set up GitHub actions, variables and secrets:

- GitHub / *Repository* / Settings
  - Actions / General
    - Workflow permissions: Read and write permissions
  - Secrets and variables / Actions / Actions secrets and variables
    - Secrets
      - **New repository secret**
        - `GH_APP_PEM_FILE` (`GITHUB_APP_PEM_FILE` contents)
        - `AWS_ACCESS_KEY_ID`
        - `AWS_SECRET_ACCESS_KEY`
    - Variables
      - **New repository variable**
        - `GH_APP_ID` (`GITHUB_APP_ID`)
        - `GH_APP_INSTALLATION_ID` (`GITHUB_APP_INSTALLATION_ID`)
        - `AWS_ENDPOINT_URL_S3`
        - `AWS_REGION`
        - `GH_OWNER` (`GITHUB_OWNER`)

## Usage

The GitHub organization YAML configuration post a Terraform plan as a pull request comment whenever a pull request to the main branch is created or whenever a new commit to the pull request is pushed. Once the pull request is merged into `main`, the plan is applied automatically.

> [!note]
> The state is stored as JSON object `github/<github owner>/terraform.tfstate` in the bucket.

### GitHub Organization YAML

The example below demonstrates the full range of capabilities available in the organization YAML configuration.

```yaml
---
organization:
  all-repositories: # OPTIONAL
    # All-repository default properties
    visibility: public # OPTIONAL, DEFAULT public
    # All-repository default features
    has_issues: true # OPTIONAL, DEFAULT false
    has_discussions: true # OPTIONAL, DEFAULT false
    has_projects: true # OPTIONAL, DEFAULT false
    has_wiki: true # OPTIONAL, DEFAULT false
    # All-repository default settings
    allow_merge_commit: false # OPTIONAL, DEFAULT true
    allow_squash_merge: true # OPTIONAL, DEFAULT true
    allow_rebase_merge: true # OPTIONAL, DEFAULT true
    allow_auto_merge: true # OPTIONAL, DEFAULT false
    delete_branch_on_merge: true # OPTIONAL, DEFAULT false
    # All-repository default rulesets
    rulesets:
      - name: "Main Branch"
        target: branch # REQUIRED, VALUES branch or tag
        enforcement: active # REQUIRED, VALUES disabled or active
        bypass_actors: # OPTIONAL, DEFAULT empty
            # Xebis GitHub Semantic Release https://github.com/apps/xebis-github-semantic-release
          - actor_id: 1527160 # REQUIRED, VALUE The ID of the actor
            actor_type: Integration # REQUIRED, VALUES RepositoryRole, Team, Integration, OR OrganizationAdmin
            bypass_mode: always # REQUIRED, VALUES always or pull_request
        conditions: # OPTIONAL, DEFAULT empty
          ref_name:
            include: # OPTIONAL, DEFAULT empty, VALUE array of ref names or patterns to include, SPECIAL VALUES ~ALL and ~DEFAULT_BRANCH also accepted
              - ~DEFAULT_BRANCH
            exclude: # OPTIONAL, DEFAULT empty
        rules:
          creation: true # OPTIONAL, DEFAULT false
          update: true # OPTIONAL, DEFAULT false
          update_allows_fetch_and_merge: false # OPTIONAL, DEFAULT false
          deletion: true # OPTIONAL, DEFAULT false
          required_linear_history: true # OPTIONAL, DEFAULT false
          required_signatures: true # OPTIONAL, DEFAULT false
          pull_request: # OPTIONAL, DEFAULT empty MEANING does not require a pull request before merging
            required_approving_review_count: 0 # OPTIONAL, DEFAULT 0
repositories:
  - name: repo-slug
    # Repository metadata
    description: Repository description. # OPTIONAL, DEFAULT none
    homepage_url: http://repo.domain/ # OPTIONAL, DEFAULT none
    topics: # OPTIONAL, DEFAULT none
      - github-topic-1
    # Repository properties
    visibility: public # OPTIONAL, DEFAULT public
    is_template: true # OPTIONAL, DEFAULT false
    # Repository features
    has_issues: true # OPTIONAL, DEFAULT false
    has_discussions: true # OPTIONAL, DEFAULT false
    has_projects: true # OPTIONAL, DEFAULT false
    has_wiki: true # OPTIONAL, DEFAULT false
    # Repository settings
    allow_merge_commit: false # OPTIONAL, DEFAULT true
    allow_squash_merge: true # OPTIONAL, DEFAULT true
    allow_rebase_merge: true # OPTIONAL, DEFAULT true
    allow_auto_merge: true # OPTIONAL, DEFAULT false
    delete_branch_on_merge: true # OPTIONAL, DEFAULT false
```

Defaults are usually the same as in the Terraform provider `github` resource `github_repository`, see [Terraform Registry / Providers / integrations / github / resources / github_repository](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository#argument-reference).

### Local Usage

Apply the configuration using Terraform:

```shell
# Environment variables
export AWS_REGION=<aws-region>
export AWS_ENDPOINT_URL_S3=<aws-endpoint-url-s3> # Only for non-AWS S3 compatible APIs
export AWS_ACCESS_KEY_ID=<aws-access-key-id>
export AWS_SECRET_ACCESS_KEY=<aws-secret-access-key>

export GITHUB_OWNER=<owner>
export GITHUB_APP_ID=<app-id>
export GITHUB_APP_INSTALLATION_ID=<app-installation-id>
export GITHUB_APP_PEM_FILE=$(cat <app-private-key.pem>)

export TF_WORKSPACE="$GITHUB_OWNER"
export TF_VAR_path="../test.yaml"

# Terraform
terraform -chdir=terraform init
terraform -chdir=terraform plan
terraform -chdir=terraform apply
```

## Development

Format Terraform configuration by `terraform -chdir=terraform fmt -recursive`.

## Testing

### Terraform Test

Run test scenarios in [`terraform/tests`](terraform/tests/) by `terraform -chdir=terraform test`.

### End-to-end Testing

This repository is tested using [`test.yaml`](test.yaml) as the configuration file for the [Xebis Test GitHub Organization](https://github.com/xebis-test) settings and repositories.

The workflow is designed to post a Terraform plan as a pull request comment whenever a pull request to the main branch is created or whenever a new commit to the pull request is pushed. Once the pull request is merged into `main`, the plan is applied automatically.

## Credits and Acknowledgments

- Martin Bružina - Author

## Copyright and Licensing

- MIT License  
  Copyright © 2025 Martin Bružina
