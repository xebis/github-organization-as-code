run "empty_file" {
  command = plan

  variables {
    path = "tests/fixtures/empty.yaml"
  }

  assert {
    condition     = local.config == null
    error_message = "Expected empty file to produce empty configuration."
  }

  assert {
    condition     = local.repositories == []
    error_message = "Expected empty file to produce empty repositories."
  }
}
