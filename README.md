# Terraform Modules for Google Cloud

_NOTE: This repository is still a work-in-progress._

This repository contains reusable but opinionated Terraform modules for Google Cloud.

For the avoidance of doubt, this repository assumes an intra-project deployment strategy (i.e. managing resources within its own project) since it should be applicable whether you belong to a Google Cloud organisation or not.

## Quickstart

This section assumes you have [Terraform](https://learn.hashicorp.com/terraform/gcp/install) and [Google Cloud SDK](https://cloud.google.com/sdk/install) installed.

### Creating service account

In order for Terraform to interact with Google Cloud, we will will need to create a service account with the appropriate roles.

```shell
gcloud iam service-accounts create [SA-NAME] \
    --description "Service account for managing Google Cloud resources with Terraform" \
    --display-name [SA-NAME]
```

### Granting IAM roles

Next, we will need to grant terraform with the following Cloud IAM roles:

#### `roles/editor`
_To manage just about every resource within the project._

```shell
gcloud projects add-iam-policy-binding [PROJECT-ID] \
    --member serviceAccount:[SA-NAME]@[PROJECT-ID].iam.gserviceaccount.com \
    --role roles/editor
```

#### `roles/resourcemanager.projectIamAdmin`
_Optional: To set IAM policies on the project._

```shell
gcloud projects add-iam-policy-binding [PROJECT-ID] \
    --member serviceAccount:[SA-NAME]@[PROJECT-ID].iam.gserviceaccount.com \
    --role roles/resourcemanager.projectIamAdmin
```

#### `roles/iam.serviceAccountAdmin`
_Optional: To set IAM policies on service accounts._

```shell
gcloud projects add-iam-policy-binding [PROJECT-ID] \
    --member serviceAccount:[SA-NAME]@[PROJECT-ID].iam.gserviceaccount.com \
    --role roles/iam.serviceAccountAdmin
```

### Generating service account key

Next, we need to generate a service account key:

```shell
gcloud iam service-accounts keys create ~/[SA-NAME].json \
    --iam-account [SA-NAME]@[PROJECT-ID].iam.gserviceaccount.com
```

Ensure that you export the name of the service account key file if you are using [Application Default Credentials](https://cloud.google.com/docs/authentication/production#finding_credentials_automatically).

```shell
export GOOGLE_APPLICATION_CREDENTIALS=[SA-NAME].json
```
