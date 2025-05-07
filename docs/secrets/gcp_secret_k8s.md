## Step 1: Store api_token in GCP Secret Manager

- Create the Secret:
```
gcloud secrets create filebeat-api-token --data-file=- <<< "<your-api-token>"

gcloud secrets versions access latest --secret=filebeat-api-token
```

## Step 2: Populate Kubernetes Secret

- Enable Workload Identity (if using GKE):

```
gcloud container clusters update <cluster-name> --workload-pool=<project-id>.svc.id.goog
```

- Install Secrets Store CSI Driver:
```
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system
```

- Create Service Account and IAM Policy:
```
gcloud iam service-accounts create filebeat-sa --project=<project-id>
gcloud projects add-iam-policy-binding <project-id> \
    --member="serviceAccount:filebeat-sa@<project-id>.iam.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"
```

- Create Kubernetes Service Account:

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: filebeat-sa
  namespace: elk
  annotations:
    iam.gke.io/gcp-service-account: filebeat-sa@<project-id>.iam.gserviceaccount.com

```

```
kubectl apply -f sa.yml
```

- Create SecretProviderClass:

```
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: filebeat-gcp-secrets
  namespace: elk
spec:
  provider: gcp
  parameters:
    secrets: |
      - resourceName: "projects/<project-number>/secrets/filebeat-api-token/versions/latest"
        fileName: "api_token"
  secretObjects:
  - secretName: filebeat-gcp-secret
    type: Opaque
    data:
    - objectName: api_token
      key: api_token
```

- Replace <project-number> with your GCP project number (find it via gcloud projects describe <project-id> --format="value(projectNumber)").
Apply:
```
kubectl apply -f secretproviderclass.yml
```

- Verify Secret
```
kubectl get secret filebeat-gcp-secret -n elk -o yaml
```
