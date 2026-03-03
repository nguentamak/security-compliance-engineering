output "group_object_ids" {
  value = {
    data_analysts   = azuread_group.groups["Data Analysts"].id
    data_engineers  = azuread_group.groups["Data Engineers"].id
    platform_admins = azuread_group.groups["Platform Admins"].id
    security_admins = azuread_group.groups["Security Admins"].id
  }
}