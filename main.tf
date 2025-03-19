locals {
  config             = yamldecode(file(var.path))
  default_properties = try(local.config.default-properties, null)
  repositories       = local.config.repositories
}

resource "github_repository" "repo" {
  for_each = { for repo in local.repositories : repo.name => repo }

  # Metadata
  name         = each.value.name
  description  = try(each.value.description, null)
  homepage_url = try(each.value.homepage_url, null)
  topics       = try(each.value.topics, null)

  # Properties
  visibility  = try(each.value.visibility, local.default_properties.visibility, null)
  is_template = try(each.value.is_template, null)

  # Features
  has_issues      = try(each.value.has_issues, local.default_properties.has_issues, null)
  has_discussions = try(each.value.has_discussions, local.default_properties.has_discussions, null)
  has_projects    = try(each.value.has_projects, local.default_properties.has_projects, null)
  has_wiki        = try(each.value.has_wiki, local.default_properties.has_wiki, null)

  # Settings
  allow_merge_commit     = try(each.value.allow_merge_commit, local.default_properties.allow_merge_commit, null)
  allow_squash_merge     = try(each.value.allow_squash_merge, local.default_properties.allow_squash_merge, null)
  allow_rebase_merge     = try(each.value.allow_rebase_merge, local.default_properties.allow_rebase_merge, null)
  allow_auto_merge       = try(each.value.allow_auto_merge, local.default_properties.allow_auto_merge, null)
  delete_branch_on_merge = try(each.value.delete_branch_on_merge, local.default_properties.delete_branch_on_merge, null)
}
