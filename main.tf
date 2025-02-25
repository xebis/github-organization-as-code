locals {
  config       = yamldecode(file("gh-org.yaml"))
  repositories = local.config.repositories
}

resource "github_repository" "repo" {
  for_each    = { for repo in local.repositories : repo.id => repo }
  name        = each.value.id
  description = each.value.description
}
