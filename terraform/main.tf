locals {
  config           = yamldecode(file(var.path))
  all_repositories = try(local.config.organization.all-repositories, null)
  repositories     = local.config.repositories
  all_repositories_rulesets = [
    for pair in setproduct(local.repositories, local.all_repositories.rulesets) : {
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
  visibility  = try(each.value.visibility, local.all_repositories.visibility, null)
  is_template = try(each.value.is_template, null)

  # Features
  has_issues      = try(each.value.has_issues, local.all_repositories.has_issues, null)
  has_discussions = try(each.value.has_discussions, local.all_repositories.has_discussions, null)
  has_projects    = try(each.value.has_projects, local.all_repositories.has_projects, null)
  has_wiki        = try(each.value.has_wiki, local.all_repositories.has_wiki, null)

  # Settings
  allow_merge_commit     = try(each.value.allow_merge_commit, local.all_repositories.allow_merge_commit, null)
  allow_squash_merge     = try(each.value.allow_squash_merge, local.all_repositories.allow_squash_merge, null)
  allow_rebase_merge     = try(each.value.allow_rebase_merge, local.all_repositories.allow_rebase_merge, null)
  allow_auto_merge       = try(each.value.allow_auto_merge, local.all_repositories.allow_auto_merge, null)
  delete_branch_on_merge = try(each.value.delete_branch_on_merge, local.all_repositories.delete_branch_on_merge, null)
}

resource "github_repository_ruleset" "all_repositories" {
  for_each = {
    for repository_ruleset in local.all_repositories_rulesets :
    format("%s/%s", "${repository_ruleset.repository.name}", replace(lower("${repository_ruleset.ruleset.name}"), " ", "_")) => repository_ruleset
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
