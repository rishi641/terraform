resource "google_monitoring_service" "car_rental_service" {
  service_id   = "car-rental-service"
  display_name = "Car Rental Service"
}

resource "google_monitoring_service_level_objective" "availability_slo" {
  service        = google_monitoring_service.car_rental_service.name
  display_name   = "Car Rental Availability SLO"
  goal           = 0.99
  rolling_period = "604800s" # 7 days

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
