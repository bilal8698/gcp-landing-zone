# Bootstrap Module for Palo Alto NGFW
# Based on PaloAltoNetworks/terraform-google-swfw-modules bootstrap patterns
# Creates GCS bucket and uploads bootstrap configuration files

# GCS bucket for bootstrap files
resource "google_storage_bucket" "bootstrap" {
  name          = var.bucket_name
  project       = var.project_id
  location      = var.location
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true

  labels = var.labels

  lifecycle_rule {
    condition {
      age = var.lifecycle_age_days
    }
    action {
      type = "Delete"
    }
  }
}

# Bootstrap directory structure
locals {
  bootstrap_dirs = [
    "config",
    "content",
    "license",
    "software",
  ]
}

# Create empty placeholder objects for directories
resource "google_storage_bucket_object" "bootstrap_dirs" {
  for_each = toset(local.bootstrap_dirs)

  name    = "${each.value}/"
  content = " "
  bucket  = google_storage_bucket.bootstrap.name
}

# Upload init-cfg.txt (basic configuration)
resource "google_storage_bucket_object" "init_cfg" {
  name    = "config/init-cfg.txt"
  content = templatefile("${path.module}/templates/init-cfg.txt.tpl", {
    hostname           = var.hostname
    panorama_server    = var.panorama_server
    panorama_server2   = var.panorama_server2
    tplname            = var.template_name
    dgname             = var.device_group_name
    vm_auth_key        = var.vm_auth_key
    op_command_modes   = var.op_command_modes
    dns_primary        = var.dns_primary
    dns_secondary      = var.dns_secondary
    ntp_primary        = var.ntp_primary
    ntp_secondary      = var.ntp_secondary
    timezone           = var.timezone
    login_banner       = var.login_banner
    vm_series_auto_reg = var.vm_series_auto_registration
  })
  bucket = google_storage_bucket.bootstrap.name

  depends_on = [google_storage_bucket_object.bootstrap_dirs]
}

# Upload bootstrap.xml (detailed XML configuration)
resource "google_storage_bucket_object" "bootstrap_xml" {
  count = var.bootstrap_xml_template != "" ? 1 : 0

  name    = "config/bootstrap.xml"
  content = templatefile(var.bootstrap_xml_template, var.bootstrap_xml_vars)
  bucket  = google_storage_bucket.bootstrap.name

  depends_on = [google_storage_bucket_object.bootstrap_dirs]
}

# Upload authcodes for licenses
resource "google_storage_bucket_object" "authcodes" {
  for_each = nonsensitive(var.authcodes)

  name    = "license/authcodes"
  content = each.value
  bucket  = google_storage_bucket.bootstrap.name

  depends_on = [google_storage_bucket_object.bootstrap_dirs]
}

# Upload custom content files
resource "google_storage_bucket_object" "content_files" {
  for_each = var.content_files

  name   = "content/${each.key}"
  source = each.value
  bucket = google_storage_bucket.bootstrap.name

  depends_on = [google_storage_bucket_object.bootstrap_dirs]
}

# Upload software files
resource "google_storage_bucket_object" "software_files" {
  for_each = var.software_files

  name   = "software/${each.key}"
  source = each.value
  bucket = google_storage_bucket.bootstrap.name

  depends_on = [google_storage_bucket_object.bootstrap_dirs]
}

# IAM binding for VM service account to access bootstrap bucket
resource "google_storage_bucket_iam_member" "vm_access" {
  bucket = google_storage_bucket.bootstrap.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.service_account_email}"
}
