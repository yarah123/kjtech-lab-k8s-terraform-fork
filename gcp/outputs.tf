output cluster_name {
  value = module.gke.name
}

output l7_global_ip {
  value = google_compute_global_address.l7_ip.address
}

output l7_global_ip_name {
  value = google_compute_global_address.l7_ip.name
}