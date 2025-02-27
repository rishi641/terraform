resource "google_monitoring_rum_application" "rum_app" {
  display_name = "Car Rental RUM App"
  type         = "WEB"
  location     = var.region
}
