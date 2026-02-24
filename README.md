# 🚀 K8s Home Lab: GitOps Edition (arthurghz)

This repository contains the SRE-grade infrastructure for a local Kubernetes Home Lab running on **Kind** (Kubernetes in Docker). It uses **ArgoCD** for GitOps and **SOPS + Age** for secret management.

The goal is to provide a robust, automated environment for experimenting with **Local LLMs**, **AI Agents**, and **Modern SRE Practices**.

### 🌟 Key Features
- **Self-Healing Infrastructure**: Everything is managed by ArgoCD (App-of-Apps pattern).
- **AI Stack ready**: Pre-installed with Ollama, Open WebUI, and Langflow.
- **Stress Testing**: Built-in benchmarking tools to optimize LLM performance for your hardware.
- **Secure Access**: Integrated with Cloudflare Tunnels for safe, remote exposure without port forwarding.
- **Secret Management**: Native Git encryption with SOPS and Age.

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

## 🚀 Current Applications & Domains

The following applications are deployed via GitOps. Once the Cloudflare tunnel is configured, they will be accessible at:

| Application | Purpose | Domain |
| :--- | :--- | :--- |
| **Grafana** | Monitoring Dashboards (K8s Metrics) | `grafana.yourdomain.com` |
| **Open WebUI** | Main Chat Interface for LLMs | `chat.yourdomain.com` |
| **LLM Benchmark** | Stress test models & hardware | `benchmark.yourdomain.com` |
| **Langflow** | Visual Agent & Workflow Creator | `agents.yourdomain.com` |
| **OpenClaw** | Classic Game Engine (Claw) | `claw.yourdomain.com` |
| **n8n** | Self-hosted Automation Tool (Low-code) | `n8n.yourdomain.com` |
| **Ollama** | Backend LLM Engine | `Internal Service` |

*Note: Replace `yourdomain.com` with your actual domain in the `/apps` YAML files.*

### 🌐 Local Access

To access the applications from your browser (e.g., `http://chat.yourdomain.com`), you need to map these domains to your local IP.

**Option 1: Quick Setup (Recommended)**
Run the helper command (requires `sudo` to edit `/etc/hosts`):
```bash
just local-dns
```

**Option 2: Manual Setup**
Add the following line to your `/etc/hosts` file:
```text
127.0.0.1 chat.yourdomain.com benchmark.yourdomain.com agents.yourdomain.com n8n.yourdomain.com claw.yourdomain.com grafana.yourdomain.com
```

## 🤖 Automated Agents & CronJobs

This lab is designed for **Headless Automation**. You can create agents that run on a schedule:

- **Example**: `apps/agent-cronjobs/daily-summary.yaml`
- **Logic**: Use standard Kubernetes `CronJob` to trigger Python scripts that call the `ollama:11434` API.
- **Workflow**: Use `n8n` to connect agents to external APIs (GitHub, Google, etc.) and trigger them via HTTP or schedule.

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
