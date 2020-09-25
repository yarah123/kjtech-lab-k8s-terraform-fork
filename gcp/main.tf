provider "google" {
  version = "~> 3.35.0"
  project = var.project_id
  region  = var.region
  user_project_override = true
}

provider external { version = "~> 1.2.0" }
provider null { version = "~> 2.1.2" }
provider random { version = "~> 2.3.0" }


resource "google_compute_network" "gke_vpc_network" {
  name                    = "gke-placeos"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnetwork" {
  name          = "gke-placeos"
  ip_cidr_range = "10.1.0.0/24"
  region        = var.region
  network       = google_compute_network.gke_vpc_network.id

  secondary_ip_range {
    range_name    = "placeos-secondary-pod"
    ip_cidr_range = "10.234.128.0/19"
  }

  secondary_ip_range {
    range_name    = "placeos-secondary-svc"
    ip_cidr_range = "10.234.192.0/19"
  }
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  version                    = "11.1.0"
  project_id                 = var.project_id
  name                       = "placeos"
  region                     = var.region
  zones                      = var.zones
  network                    = google_compute_network.gke_vpc_network.name
  subnetwork                 = google_compute_subnetwork.gke_subnetwork.name
  ip_range_pods              = "placeos-secondary-pod"
  ip_range_services          = "placeos-secondary-svc"
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = true
  logging_service            = "none"
  monitoring_service         = "none"
  create_service_account       = false
  node_pools = [
    {
      name               = "placeos-node-pool"
      machine_type       = "n1-standard-2"
      min_count          = 1
      max_count          = 2
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = true
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    placeos-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    placeos-node-pool = {
      default-node-pool = "true"
    }
  }

  node_pools_metadata = {
    all = {}

    placeos-node-pool = {
      node-pool-metadata-custom-value = "placeos-applications"
    }
  }


  node_pools_tags = {
    all = []

    placeos-node-pool = [
      "placeos-node-pool",
    ]
  }
}
