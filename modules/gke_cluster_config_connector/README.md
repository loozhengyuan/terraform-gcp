# Config Connector on GKE

## Notes

* This feature [requires partial installation](https://cloud.google.com/config-connector/docs/how-to/install-upgrade-uninstall#installing_kcc) using `kubectl`.
* This feature should ideally be installed in a [single GKE cluster](https://cloud.google.com/config-connector/docs/concepts/namespaces-and-projects#configuring_your_namespaces) within a project.
* Use the default `[PROJECT_ID]` Kubernetes namespace or use [override annotations](https://cloud.google.com/config-connector/docs/how-to/setting-default-namespace) to associate a custom Kubernetes namespace with a GCP Project.

## Known Issues

* Service account IAM role assignment [will fail](https://github.com/terraform-providers/terraform-provider-google/issues/4276) when existing IAM `roles/owner` members have non-lowercase IDs.
