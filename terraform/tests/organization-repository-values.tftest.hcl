run "organization_repository_repositories" {
  command = plan

  variables {
    path = "tests/fixtures/organization-repository-values.yaml"
  }

  assert {
    condition     = local.config.repositories != []
    error_message = "Expected defaults config file to produce non-empty repositories local."
  }

  assert {
    condition     = length(local.config.repositories) == 1
    error_message = "Expected defaults config file to produce exactly one repository."
  }

  assert {
    condition     = local.config.repositories[0].name == "example"
    error_message = "Expected defaults config file to produce the repository named 'example'."
  }
}

run "organization_repository_repositories_values" {
  command = plan

  variables {
    path = "tests/fixtures/organization-repository-values.yaml"
  }

  assert {
    condition     = local.repositories == [{
      name                   = "example"
      description            = "An example repository"
      homepage_url           = "https://example.com"
      topics                 = ["example-topic"]
      visibility             = "private"
      is_template            = true
      has_issues             = true
      has_discussions        = true
      has_projects           = true
      has_wiki               = true
      allow_merge_commit     = true
      allow_squash_merge     = true
      allow_rebase_merge     = true
      allow_auto_merge       = true
      delete_branch_on_merge = true
    }]
    error_message = "The example repository expected to be set to concrete values."
  }
}
