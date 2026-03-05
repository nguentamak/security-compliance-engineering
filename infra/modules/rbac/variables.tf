variable "assignments" {
  description = <<EOT
Map of role assignments:
- key: logical name
- value:
  - scope: Azure resource ID
  - role_definition_name: built-in role name (e.g. Reader, Contributor, Storage Blob Data Reader)
  - principal_id: object ID (user/group/service principal/managed identity)
EOT
  type = map(object({
    scope                = string
    role_definition_name = string
    principal_id         = string
  }))
}