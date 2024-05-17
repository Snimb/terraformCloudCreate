resource "biganimal_region" "this" {
  cloud_provider = "azure"
  region_id      = "eu-west-1"
  project_id     = var.project_id
}

resource "random_pet" "project_name" {
  separator = " "
}

resource "biganimal_project" "this" {
  project_name = format("TF %s", title(random_pet.project_name.id))
}