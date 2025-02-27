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

module "project_setup" {
  source      = "./modules/gcp-project-setup"
  project_id  = var.project_id
  region      = var.region
}

module "rum" {
  source      = "./modules/gcp-rum"
  project_id  = var.project_id
  region      = var.region
}

module "synthetic_monitor" {
  source      = "./modules/gcp-synthetic-monitor"
  project_id  = var.project_id
  region      = var.region
}

module "service_slo" {
  source      = "./modules/gcp-service-slo"
  project_id  = var.project_id
  region      = var.region
}

module "dashboard" {
  source      = "./modules/gcp-dashboard"
  project_id  = var.project_id
  region      = var.region
}

module "metric_alerting" {
  source      = "./modules/gcp-metric-alerting"
  project_id  = var.project_id
  region      = var.region
}

module "logging" {
  source      = "./modules/gcp-logging"
  project_id  = var.project_id
  region      = var.region
}
