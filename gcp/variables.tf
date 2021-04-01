variable region {

}

variable zones {

}

variable project_id {

}

variable http_loadbalancing {
    description = "enable the default http loadbalancer config for GKE"
    type = bool
    default = false
}

variable "google_compute_address_type" {
    description = "will backoffice lb be a private or a public ip address"
    default = "EXTERNAL"
}