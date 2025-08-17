# MC Helm Charts

This repository contains all custom Helm charts for Manning Capital's Kubernetes deployments.

## Quick Start

### Add the Repository

```bash
helm repo add mc-helm https://raw.githubusercontent.com/manning-capital/mc-helm/main/
helm repo update
```

### Install a Chart

```bash
# Install deploy-prefect chart
helm install deploy-prefect mc-helm/deploy-prefect \
  --set image.repository=ghcr.io/manning-capital/your-image \
  --set image.tag=latest
```

## Charts

### [deploy-prefect](./charts/deploy-prefect/)

A Helm chart for deploying Prefect flows using Kubernetes Jobs. This chart creates a Kubernetes Job that runs Prefect flow deployment scripts in a containerized environment.

**Features:**
- Automated Prefect flow deployment
- Configurable resource limits and job parameters
- Security-focused with non-root execution
- Environment variable management
- Automatic cleanup of completed jobs
- **Python-based deployment logic** for better maintainability and error handling

**Install:**
```bash
helm install deploy-prefect mc-helm/deploy-prefect \
  --set image.repository=ghcr.io/manning-capital/your-image \
  --set image.tag=latest
```

## Repository Management

### Automatic Updates (GitHub Actions)

The repository is automatically updated when charts are modified. The GitHub Actions workflow:
1. Packages all charts
2. Updates the repository index
3. Commits and pushes changes

### Manual Updates

To manually update the repository:

```bash
# Run the update script
./scripts/update-repo.sh

# Or manually package and index
helm package charts/deploy-prefect/ --destination charts/
helm repo index charts/ --url https://raw.githubusercontent.com/manning-capital/mc-helm/main/
```

## Repository Structure

```
mc-helm/
├── charts/                    # Helm charts directory
│   ├── deploy-prefect/       # Prefect deployment chart
│   │   ├── Chart.yaml        # Chart metadata
│   │   ├── values.yaml       # Default values
│   │   ├── values-example.yaml # Example configuration
│   │   ├── templates/        # Kubernetes manifests
│   │   ├── scripts/          # Python deployment scripts
│   │   └── README.md         # Chart documentation
│   └── *.tgz                 # Packaged charts (auto-generated)
├── scripts/                   # Utility scripts
│   └── update-repo.sh        # Repository update script
├── .github/workflows/         # GitHub Actions
│   └── update-repo.yml       # Auto-update workflow
├── index.yaml                 # Repository index (auto-generated)
├── LICENSE                    # Repository license
└── README.md                  # This file
```

## Development

### Prerequisites

- Helm 3.x
- Kubernetes cluster access
- kubectl configured

### Testing Charts

```bash
# Lint a chart
helm lint charts/chart-name/

# Test template rendering
helm template charts/chart-name/ --dry-run

# Install for testing
helm install test-release charts/chart-name/ --dry-run
```

### Adding New Charts

1. Create a new directory in `charts/`
2. Follow the existing chart structure
3. Include comprehensive documentation
4. Add validation for required values
5. Test with `helm lint` and `helm template`
6. Update this README with chart information

### Updating Existing Charts

1. Modify the chart in `charts/chart-name/`
2. Update the version in `Chart.yaml`
3. Test the changes
4. Commit and push - the repository will auto-update

## Usage Examples

### Install with Custom Values

```bash
# Create a values file
cat > my-values.yaml << EOF
image:
  repository: ghcr.io/manning-capital/my-image
  tag: v1.2.3
config:
  prefectApiUrl: https://my-prefect.example.com/api
env:
  ENVIRONMENT: production
  LOG_LEVEL: INFO
EOF

# Install with custom values
helm install deploy-prefect mc-helm/deploy-prefect -f my-values.yaml
```

### Upgrade Existing Installation

```bash
helm upgrade deploy-prefect mc-helm/deploy-prefect \
  --set image.tag=v1.2.4
```

### Uninstall

```bash
helm uninstall deploy-prefect
```

## Security

All charts follow security best practices:
- Non-root execution
- Capability dropping
- Privilege escalation prevention
- Configurable security contexts

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.
