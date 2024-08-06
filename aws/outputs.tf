output "client_key" {
    value = aws_kubernetes_cluster.placeos.kube_config.0.client_key
    sensitive = true
}

output "client_certificate" {
    value = aws_kubernetes_cluster.placeos.kube_config.0.client_certificate
    sensitive = true
}

output "cluster_ca_certificate" {
    value = aws_kubernetes_cluster.placeos.kube_config.0.cluster_ca_certificate
    sensitive = true
}

output "cluster_username" {
    value = aws_kubernetes_cluster.placeos.kube_config.0.username
    sensitive = true
}

output "cluster_password" {
    value = aws_kubernetes_cluster.placeos.kube_config.0.password
    sensitive = true
}

output "kube_config" {
    value = aws_kubernetes_cluster.placeos.kube_config_raw
    sensitive = true
}

output "host" {
    value = aws_kubernetes_cluster.placeos.kube_config.0.host
    sensitive = true
}
