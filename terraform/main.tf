locals {
  config = yamldecode(file(var.path))

  repositories = [
    for repository in try(local.config.repositories, []) : {
      # Metadata
      name         = repository.name
      description  = try(repository.description, null)
      homepage_url = try(repository.homepage_url, null)
      topics       = try(repository.topics, null)
      # Properties
      visibility  = try(repository.visibility, local.config.organization.all-repositories.visibility, null)
      is_template = try(repository.is_template, null)
      # Features
      has_issues      = try(repository.has_issues, local.config.organization.all-repositories.has_issues, null)
      has_discussions = try(repository.has_discussions, local.config.organization.all-repositories.has_discussions, null)
      has_projects    = try(repository.has_projects, local.config.organization.all-repositories.has_projects, null)
      has_wiki        = try(repository.has_wiki, local.config.organization.all-repositories.has_wiki, null)
      # Settings
      allow_merge_commit     = try(repository.allow_merge_commit, local.config.organization.all-repositories.allow_merge_commit, null)
      allow_squash_merge     = try(repository.allow_squash_merge, local.config.organization.all-repositories.allow_squash_merge, null)
      allow_rebase_merge     = try(repository.allow_rebase_merge, local.config.organization.all-repositories.allow_rebase_merge, null)
      allow_auto_merge       = try(repository.allow_auto_merge, local.config.organization.all-repositories.allow_auto_merge, null)
      delete_branch_on_merge = try(repository.delete_branch_on_merge, local.config.organization.all-repositories.delete_branch_on_merge, null)
    }
  ]

  all_repositories = try(local.config.organization.all-repositories, [])
  repositories0    = try(local.config.repositories, [])
  all_repositories_rulesets = [
    for pair in try(setproduct(local.repositories0, local.all_repositories.rulesets), []) : {
      repository = pair[0],
      ruleset    = pair[1]
    }
  ]
}

resource "github_repository" "repo" {
  for_each = { for repository in local.repositories : repository.name => repository }

  # Metadata
  name         = each.value.name
  description  = each.value.description
  homepage_url = each.value.homepage_url
  topics       = each.value.topics

  # Properties
  visibility  = each.value.visibility
  is_template = each.value.is_template

  # Features
  has_issues      = each.value.has_issues
  has_discussions = each.value.has_discussions
  has_projects    = each.value.has_projects
  has_wiki        = each.value.has_wiki

  # Settings
  allow_merge_commit     = each.value.allow_merge_commit
  allow_squash_merge     = each.value.allow_squash_merge
  allow_rebase_merge     = each.value.allow_rebase_merge
  allow_auto_merge       = each.value.allow_auto_merge
  delete_branch_on_merge = each.value.delete_branch_on_merge
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

  # Bypass actors
  dynamic "bypass_actors" {
    for_each = try(each.value.ruleset.bypass_actors, [])
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

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
