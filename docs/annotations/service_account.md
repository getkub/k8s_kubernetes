## Adding annotation to SErvice Account to get access to vault (eg for GCP)

### annotation to sa
```
iam.gke.io/gcp-service-account: my-token-view@my-project-name.iam.gserviceaccount.com
```

### Then Add to the role in cloud console
```
gcloud iam service-accounts add-iam-policy-binding my-token-view@my-project-name.iam.gserviceaccount.com \
--role "roles/iam.workloadIdentityUser" \
--member "serviceAccount:my-project-name.svc.id.goog[my-ns/my-workload-name]"
```
