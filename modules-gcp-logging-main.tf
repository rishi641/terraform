resource "google_storage_bucket" "log_bucket" {
  name     = "${var.project_id}-logs"
  location = var.region
}

resource "google_logging_project_sink" "centralized_logging" {
  name        = "car-rental-logs-sink"
  destination = "storage.googleapis.com/${google_storage_bucket.log_bucket.name}"
  filter      = "resource.type=gce_instance"
}

resource "google_logging_metric" "error_metric" {
  name = "car_rental_error_metric"
  filter = "severity>=ERROR"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "log_anomaly_alert" {
  display_name = "Car Rental Log Anomaly Alert"
  combiner     = "OR"

  conditions {
    display_name = "High Error Log Rate"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/car_rental_error_metric\""
      comparison      = "COMPARISON_GT"
      threshold_value = 10
      duration        = "300s"
      aggregations {
        alignment_period  = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}
