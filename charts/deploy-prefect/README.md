# Deploy Prefect Helm Chart

This Helm chart deploys a Kubernetes Job that runs Prefect flow deployment scripts.

## Chart Structure

```
charts/deploy-prefect/
├── Chart.yaml                 # Chart metadata
├── values.yaml               # Default values
├── templates/                # Kubernetes manifests
│   ├── _helpers.tpl         # Template helpers
│   └── deploy-prefect-job.yaml # Job template
└── README.md                 # This file
```

## Usage

### From GitHub Actions (Recommended)

The chart is automatically deployed in the GitHub workflow with all necessary values:

```yaml
- name: Deploy to Digital Ocean cluster
  run: |
    cd .github/k8s
    helm upgrade --install deploy-prefect . \
      --set image.repository=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }} \
      --set image.tag=${{ steps.meta.outputs.tags }} \
      --set config.prefectApiUrl=${{ env.PREFECT_API_URL }} \
      --set env.GITHUB_TOKEN=${{ secrets.GITHUB_TOKEN }} \
      --set env.PREFECT_GITHUB_CREDENTIALS=${{ secrets.PREFECT_GITHUB_CREDENTIALS }} \
      --set env.POSTGRES_URL=${{ secrets.POSTGRES_URL }}
```

### Manual Deployment

1. **Install the chart:**
   ```bash
   cd charts/deploy-prefect
   helm install deploy-prefect . \
     --set image.repository=ghcr.io/your-org/your-image \
     --set image.tag=v1.0.0 \
     --set config.prefectApiUrl=https://prefect.example.com/api \
     --set env.GITHUB_TOKEN=your-token \
     --set env.PREFECT_GITHUB_CREDENTIALS=your-credentials \
     --set env.POSTGRES_URL=your-postgres-url
   ```

2. **Upgrade existing deployment:**
   ```bash
   helm upgrade deploy-prefect . \
     --set image.tag=v1.1.0
   ```

3. **Uninstall:**
   ```bash
   helm uninstall deploy-prefect
   ```

## Configuration

### Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Docker image repository | **Required** |
| `image.tag` | Docker image tag | **Required** |
| `image.pullPolicy` | Image pull policy | `Always` |
| `config.prefectApiUrl` | Prefect API URL | `http://prefect-server.prefect.svc.cluster.local:4200/api` |
| `env.*` | Environment variables | `{}` |
| `resources.requests.memory` | Memory request | `128Mi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.limits.memory` | Memory limit | `256Mi` |
| `resources.limits.cpu` | CPU limit | `200m` |
| `job.parallelism` | Job parallelism | `1` |
| `job.completions` | Job completions | `1` |
| `job.activeDeadlineSeconds` | Job timeout | `1800` (30 min) |
| `job.ttlSecondsAfterFinished` | Cleanup delay | `300` (5 min) |
| `job.backoffLimit` | Retry limit | `3` |
| `securityContext.runAsUser` | User ID to run as | `1000` |
| `securityContext.runAsGroup` | Group ID to run as | `1000` |
| `securityContext.fsGroup` | File system group | `1000` |

### Override Values

Create a custom `values.yaml` file:

```yaml
image:
  repository: ghcr.io/your-org/custom-image
  tag: v2.0.0

config:
  prefectApiUrl: https://staging.prefect.example.com/api

resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
```

Then deploy with:
```bash
helm install deploy-prefect . -f custom-values.yaml
```

### Setting Environment Variables via Command Line

You can also override environment variables directly:

```bash
helm install deploy-prefect . \
  --set env.LOG_LEVEL=DEBUG \
  --set env.ENVIRONMENT=staging \
  --set env.DEBUG=true \
  --set env.CUSTOM_VAR=my_value
```

### Setting Environment Variables in GitHub Actions

```yaml
- name: Deploy to Digital Ocean cluster
  run: |
    cd charts/deploy-prefect
    helm upgrade --install deploy-prefect . \
      --set image.repository=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }} \
      --set image.tag=${{ steps.meta.outputs.tags }} \
      --set config.prefectApiUrl=${{ env.PREFECT_API_URL }} \
      --set env.GITHUB_TOKEN=${{ secrets.GITHUB_TOKEN }} \
      --set env.PREFECT_GITHUB_CREDENTIALS=${{ secrets.PREFECT_GITHUB_CREDENTIALS }} \
      --set env.POSTGRES_URL=${{ secrets.POSTGRES_URL }} \
      --set env.ENVIRONMENT=${{ env.ENVIRONMENT }} \
      --set env.LOG_LEVEL=${{ env.LOG_LEVEL }} \
      --set env.CUSTOM_VAR=${{ env.CUSTOM_VAR }}
```

## What the Job Does

1. **Sets Variables** - Runs `data/variables_base.py` to configure Prefect API URL and GitHub branch
2. **Sets Secrets** - Runs `data/secrets_base.py` to configure GitHub token, Prefect credentials, and PostgreSQL URL
3. **Deploys Code** - Finds and runs all `*_deploy.py` files recursively in the `src` directory

## Security Features

- **Non-root execution**: Runs as user/group 1000
- **Privilege escalation disabled**: Prevents privilege escalation attacks
- **Capability dropping**: Drops all Linux capabilities
- **Read-only root filesystem**: Configurable for enhanced security

## Benefits of Helm

- **Clean separation** of configuration from manifests
- **Easy parameterization** without complex sed commands
- **Version control** for your deployments
- **Rollback capability** with `helm rollback`
- **Template inheritance** and reusable components
- **Standard Kubernetes tooling** that teams are familiar with
- **Validation**: Required values are enforced at template time
