output "bucket_name" {
  description = "Name of the bootstrap bucket"
  value       = google_storage_bucket.bootstrap.name
}

output "bucket_url" {
  description = "URL of the bootstrap bucket"
  value       = google_storage_bucket.bootstrap.url
}

output "bucket_self_link" {
  description = "Self link of the bootstrap bucket"
  value       = google_storage_bucket.bootstrap.self_link
}

output "bucket_location" {
  description = "Location of the bootstrap bucket"
  value       = google_storage_bucket.bootstrap.location
}
