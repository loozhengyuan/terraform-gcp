output "cluster" {
  value       = google_container_cluster.cluster
  description = "The Kubernetes cluster."
}

output "node_pools" {
  value       = google_container_node_pool.node_pool
  description = "The Kubernetes node pools associated with the cluster."
}
