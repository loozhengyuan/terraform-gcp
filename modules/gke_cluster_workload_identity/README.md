# Workload Identity on GKE

## Notes

* Input variable `gsa_name` should be unique within a project.
* Input variable `namespace` and `ksa_name` [should be unique within a workload identity pool](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#sharing_identities_across_clusters) (which is a project-level resource).

## Known Issues

* Service account IAM role assignment [will fail](https://github.com/terraform-providers/terraform-provider-google/issues/4276) when existing IAM `roles/owner` members have non-lowercase IDs.
