# Homelab Architecture

This repository follows the **GitOps** pattern using **ArgoCD** to manage a local Kubernetes cluster (Kind).

## Directory Structure

- `bootstrap/`: The entry point for ArgoCD. Contains the "App of Apps" pattern.
  - `root.yaml`: The parent application that manages `infrastructure.yaml` and `apps.yaml`.
  - `infrastructure.yaml`: Manages baseline cluster services (Ingress, ExternalDNS, Monitoring).
  - `apps.yaml`: Manages user-facing applications in the `apps/` directory.
- `infrastructure/`: Base configurations for cluster-wide services.
  - `kind-config.yaml`: Local Kubernetes cluster setup with Ingress support.
  - `values.yaml`: Shared settings (domains, Cloudflare tunnel IDs).
- `apps/`: Individual application manifests (Ollama, WebUI, etc.).
- `docs/`: Technical documentation.
- `agent/`: Instructions for AI agents (Gemini) on how to interact with this repository.
- `scripts/`: Automation scripts for cluster lifecycle.

## Deployment Flow

1. **Bootstrap**: Run `kubectl apply -f bootstrap/root.yaml`.
2. **Infrastructure**: ArgoCD detects `infrastructure.yaml` and deploys the networking stack.
3. **Applications**: ArgoCD detects `apps.yaml`, which recursively syncs everything inside the `apps/` folder.

## Network Access

Services are exposed via **Nginx Ingress** and integrated with **Cloudflare Tunnels** for secure remote access.
