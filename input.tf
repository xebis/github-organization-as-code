variable "path" {
  type        = string
  description = "GitHub Organization configuration YAML"
  validation {
    condition     = fileexists(var.path)
    error_message = "File ${var.path} doesn't exist."
  }
}
