resource "google_monitoring_alert_policy" "cpu_alert" {
  display_name = "Car Rental High CPU Alert"
  combiner     = "OR"

  conditions {
    display_name = "High CPU Usage"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "300s"
      aggregations {
        alignment_period  = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  # (Notification channels can be configured here)
}

resource "google_monitoring_alert_policy" "forecast_alert" {
  display_name = "Forecast CPU Alert"
  combiner     = "OR"

  conditions {
    display_name = "Forecast High CPU Usage"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.85
      duration        = "300s"
      aggregations {
        alignment_period  = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
}

resource "google_monitoring_alert_policy" "disk_space_alert" {
  display_name = "Disk Space Low Alert"
  combiner     = "OR"

  conditions {
    display_name = "Low Disk Space"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/disk/bytes_used\" resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = 80000000000 # e.g., alert when >80GB used; adjust as needed
      duration        = "300s"
      aggregations {
        alignment_period  = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
}
