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
      host = "35.200.143.87" # Replace with your VM's public IP - Consider making this a variable if it needs to be configurable
    }
  }
}
