locals {
  config              = yamldecode(file(var.path))
  repository_defaults = try(local.config.organization.repository-defaults, null)
  repositories        = local.config.repositories
  repo_ruleset_combinations = [
    for pair in setproduct(local.repositories, local.repository_defaults.rulesets) : {
      repository = pair[0]
      ruleset    = pair[1]
    }
  ]
}

resource "github_repository" "repo" {
  for_each = { for repo in local.repositories : repo.name => repo }

  # Metadata
  name         = each.value.name
  description  = try(each.value.description, null)
  homepage_url = try(each.value.homepage_url, null)
  topics       = try(each.value.topics, null)

  # Properties
  visibility  = try(each.value.visibility, local.repository_defaults.visibility, null)
  is_template = try(each.value.is_template, null)

  # Features
  has_issues      = try(each.value.has_issues, local.repository_defaults.has_issues, null)
  has_discussions = try(each.value.has_discussions, local.repository_defaults.has_discussions, null)
  has_projects    = try(each.value.has_projects, local.repository_defaults.has_projects, null)
  has_wiki        = try(each.value.has_wiki, local.repository_defaults.has_wiki, null)

  # Settings
  allow_merge_commit     = try(each.value.allow_merge_commit, local.repository_defaults.allow_merge_commit, null)
  allow_squash_merge     = try(each.value.allow_squash_merge, local.repository_defaults.allow_squash_merge, null)
  allow_rebase_merge     = try(each.value.allow_rebase_merge, local.repository_defaults.allow_rebase_merge, null)
  allow_auto_merge       = try(each.value.allow_auto_merge, local.repository_defaults.allow_auto_merge, null)
  delete_branch_on_merge = try(each.value.delete_branch_on_merge, local.repository_defaults.delete_branch_on_merge, null)
}

resource "github_repository_ruleset" "this" {
  for_each = {
    for combo in local.repo_ruleset_combinations :
    "${combo.repository.name}-${combo.ruleset.name}" => combo
  }

  # Metadata
  name        = each.value.ruleset.name
  repository  = each.value.repository.name
  target      = try(each.value.ruleset.target, null)
  enforcement = try(each.value.ruleset.enforcement, null)

  # Conditions
  dynamic "conditions" {
    for_each = try(length(each.value.ruleset.conditions) > 0 ? [each.value.ruleset.conditions] : [], [])
    content {
      ref_name {
        include = try(each.value.ruleset.conditions.ref_name.include, [])
        exclude = try(each.value.ruleset.conditions.ref_name.exclude, [])
      }
    }
  }

  # Rules
  rules {
    # Lifecycle rules
    creation                      = try(each.value.ruleset.rules.creation, null)
    update                        = try(each.value.ruleset.rules.update, null)
    update_allows_fetch_and_merge = try(each.value.ruleset.rules.update_allows_fetch_and_merge, null)
    deletion                      = try(each.value.ruleset.rules.deletion, null)

    # Commit and history rules
    required_linear_history = try(each.value.ruleset.rules.required_linear_history, null)
    required_signatures     = try(each.value.ruleset.rules.required_signatures, null)

    # PR rules
    dynamic "pull_request" {
      for_each = try(length(each.value.ruleset.rules.pull_request) > 0 ? [each.value.ruleset.rules.pull_request] : [], [])
      content {
        required_approving_review_count = try(pull_request.value.required_approving_review_count, null)
      }
    }
  }
}
