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
