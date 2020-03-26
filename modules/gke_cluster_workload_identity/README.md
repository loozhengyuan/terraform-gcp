# Workload Identity on GKE

## Notes

* This Workload Identity KSA-GSA binding is project-scoped, cluster-agnostic mapping, i.e. the binding is [valid across clusters as long as the KSA matches](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#sharing_identities_across_clusters) the following identifier: `serviceAccount:GCP_PROJECT.svc.id.goog[K8S_NAMESPACE/KSA_NAME]`. As such, it is helpful if input variables `namespace` and `ksa_name` is unique within the workload identity pool.
* Input variable `namespace` expects an already-created Kubernetes namespace.
* Input variable `gsa_name` and `gsa_email` should reference an existing GSA resource.

## Known Issues

* Service account IAM role assignment [will fail](https://github.com/terraform-providers/terraform-provider-google/issues/4276) when existing IAM `roles/owner` members have non-lowercase IDs.
