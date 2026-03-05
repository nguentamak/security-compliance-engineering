principal_object_ids = {
  grp_data_analysts   = "a08db396-611f-4f86-b206-58d0890bcbdb"
  grp_data_engineers  = "a7f13d23-e7f4-46dd-bf1c-2638f89be72c"
  grp_platform_admins = "ccb1a8d3-ec7c-4717-b9e9-e209fa20fe19"
  grp_security_admins = "f68ecea1-a2b7-4a47-8ddc-8accc6e0c6e7"

  # Object ID (principal) de la Managed Identity ADF (ou SP utilisé par ADF runtime)
  mi_adf_runtime = "6c4275ab-7fcc-4067-bcd2-5a09f9d3b7a6"

  # Object ID (principal) de la Managed Identity Databricks (ou SP runtime)
  mi_databricks_runtime = "6c4275ab-7fcc-4067-bcd2-5a09f9d3b7a6"

  # Object ID du Service Principal CI/CD (ou MI CI/CD)
  sp_cicd_deployer = "05b11765-0c62-41fc-b1eb-b4d0e9958c68"
}