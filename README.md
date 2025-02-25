# GitHub Organization as Code

Streamline GitHub organization repository management with YAML configuration, GitHub workflows, and GitHub App installation—powered by Terraform under the hood.

## Features

Automate GitHub organization repository creation with YAML configuration, powered by Terraform and GitHub App integration.

### Fun Fact

This GitHub repository was automatically created using the code in this repository.

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
