run "defaults_file_repositories" {
  command = plan

  variables {
    path = "tests/fixtures/defaults.yaml"
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

run "defaults_file_repositories_values" {
  command = plan

  variables {
    path = "tests/fixtures/defaults.yaml"
  }

  assert {
    condition = local.repositories == [{
      name                   = "example"
      description            = null
      homepage_url           = null
      topics                 = null
      visibility             = null
      is_template            = null
      has_issues             = null
      has_discussions        = null
      has_projects           = null
      has_wiki               = null
      allow_merge_commit     = null
      allow_squash_merge     = null
      allow_rebase_merge     = null
      allow_auto_merge       = null
      delete_branch_on_merge = null
    }]
    error_message = "The example repository defaults expected to be null."
  }
}
