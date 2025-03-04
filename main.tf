locals {
  config             = yamldecode(file(var.path))
  default_properties = try(local.config.default-properties, null)
  repositories       = local.config.repositories
}

resource "github_repository" "repo" {
  for_each = { for repo in local.repositories : repo.name => repo }
  name     = each.value.name

  description     = try(each.value.description, null)
  topics          = try(each.value.topics, null)
  visibility      = try(each.value.visibility, local.default_properties.visibility, null)
  has_issues      = try(each.value.has_issues, local.default_properties.has_issues, null)
  has_discussions = try(each.value.has_discussions, local.default_properties.has_discussions, null)
  has_projects    = try(each.value.has_projects, local.default_properties.has_projects, null)
  has_wiki        = try(each.value.has_wiki, local.default_properties.has_wiki, null)
}
