terraform {
  required_version = ">= 0.14"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

##############################
# Enable Required APIs
##############################

resource "google_project_service" "monitoring" {
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "logging" {
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudtrace" {
  service            = "cloudtrace.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "rum" {
  service            = "monitoringrum.googleapis.com"
  disable_on_destroy = false
}

##############################
# Real User Monitoring (RUM)
##############################

resource "google_monitoring_rum_application" "rum_app" {
  display_name = "Car Rental RUM App"
  type         = "WEB"
  location     = var.region
}

##############################
# Synthetic Monitors (Uptime Check)
##############################

resource "google_monitoring_uptime_check_config" "synthetic_check" {
  display_name = "Car Rental Synthetic Check"
  timeout      = "10s"
  period       = "60s"

  http_check {
    request_method = "GET"
    path           = "/"
    port           = 80
  }

  monitored_resource {
    type   = "uptime_url"
    labels = {
      host = "35.200.143.87"  # Replace with your VM's public IP
    }
  }
}

##############################
# Service & SLO Tracking
##############################

resource "google_monitoring_service" "car_rental_service" {
  service_id   = "car-rental-service"
  display_name = "Car Rental Service"
}

resource "google_monitoring_service_level_objective" "availability_slo" {
  service        = google_monitoring_service.car_rental_service.name
  display_name   = "Car Rental Availability SLO"
  goal           = 0.99
  rolling_period = "604800s"  # 7 days

  service_level_indicator {
    basic_sli {
      latency {
        threshold = "0.5s"
        percentiles {
          percentile = 0.95
        }
      }
    }
  }
}

##############################
# Dashboards
##############################

resource "google_monitoring_dashboard" "car_rental_dashboard" {
  dashboard_json = jsonencode({
    displayName = "Car Rental Dashboard"
    gridLayout  = {
      columns = 2
      widgets = [
        {
          title   = "Uptime Check Response Time"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                prometheusQuery = "uptime_check_http_response_time{project_id=\"${var.project_id}\"}"
              }
            }]
          }
        },
        {
          title   = "CPU Utilization"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                prometheusQuery = "compute.googleapis.com/instance/cpu/utilization"
              }
            }]
          }
        }
      ]
    }
  })
}

##############################
# Metric Anomaly Alerting
##############################

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
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  # (Notification channels can be configured here)
}

##############################
# Metric Forecast-Based Alerting (Example)
##############################

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
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
}

##############################
# Log Management: Centralized Logging
##############################

resource "google_storage_bucket" "log_bucket" {
  name     = "${var.project_id}-logs"
  location = var.region
}

resource "google_logging_project_sink" "centralized_logging" {
  name        = "car-rental-logs-sink"
  destination = "storage.googleapis.com/${google_storage_bucket.log_bucket.name}"
  filter      = "resource.type=gce_instance"
}

##############################
# Log Anomaly Detection
##############################

resource "google_logging_metric" "error_metric" {
  name   = "car_rental_error_metric"
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
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

##############################
# Standard Other Alerting: Sample Disk Space Alert
##############################

resource "google_monitoring_alert_policy" "disk_space_alert" {
  display_name = "Disk Space Low Alert"
  combiner     = "OR"

  conditions {
    display_name = "Low Disk Space"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/disk/bytes_used\" resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = 80000000000  # e.g., alert when >80GB used; adjust as needed
      duration        = "300s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
}
