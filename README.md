# 🚀 K8s Home Lab: GitOps Edition (arthurghz)

This repository contains the SRE-grade infrastructure for a local Kubernetes Home Lab running on **Kind** (Kubernetes in Docker). It uses **ArgoCD** for GitOps and **SOPS + Age** for secret management.

## 📚 Quick Links

- [**Architecture**](docs/ARCHITECTURE.md): Technical overview of the cluster and GitOps flow.
- [**Applications**](docs/APPLICATIONS.md): List of installed apps (LLMs, OpenWebUI, Benchmarking, etc.).
- [**Agent Instructions**](agent/GEMINI.md): Guidelines for Gemini and other AI agents interacting with this repo.

## 🛠️ Prerequisites & Installation

Before starting, ensure you have **Docker** installed. Then, use our automation to install the rest of the SRE toolset.

### 1. Install SRE Tools
If you have `just` installed, run:
```bash
just install-tools
```
*This will install: Kind, Kubectl, Helm, SOPS, Age, and ArgoCD CLI.*

### 2. Manual Installation (Linux)
If you don't have `just` yet:
```bash
sudo apt update && sudo apt install docker.io just -y
sudo usermod -aG docker $USER && newgrp docker
```

## 🏗️ Architecture Stack

- **GitOps**: ArgoCD (App of Apps pattern).
- **Ingress**: Ingress-Nginx + Cloudflare Tunnel (`cloudflared`).
- **DNS**: ExternalDNS (auto-syncing Ingress hosts to Cloudflare).
- **Observability**: Prometheus & Grafana (kube-prometheus-stack).
- **Apps**: HomeDashboard, Ollama, Open WebUI, UptimeKuma.

## 🔐 Secret Management

We use **Mozilla SOPS** with **Age** to keep secrets safe in Git.

1.  **Initialize Age:** Run `just init-sops`.
2.  **Update `.sops.yaml`:** Copy the public key printed in step 1 into your `.sops.yaml` file.
3.  **Create Secrets:**
    ```bash
    just gen-cf-secret
    # Edit the file with your tokens...
    just encrypt infrastructure/secrets/cloudflare.secret.yaml
    ```

## 🚀 Getting Started

Simply run:
```bash
just run
```

This command will:
1. Optimize Linux `inotify` limits.
2. Create a Kind cluster with optimized port mapping.
3. Inject your private Age key into the cluster.
4. Bootstrap ArgoCD and apply the Root Application.

---
**⚠️ Note:** Data is ephemeral (EmptyDir). Destroying the cluster will wipe all data. Always back up your `~/.age/homelab.txt` file!
