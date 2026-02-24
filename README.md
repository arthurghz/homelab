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
| **Grafana** | Monitoring Dashboards (K8s Metrics) | `grafana.unbund.com` |
| **Open WebUI** | Main Chat Interface for LLMs | `chat.unbund.com` |
| **LLM Benchmark** | Stress test models & hardware | `benchmark.unbund.com` |
| **Langflow** | Visual Agent & Workflow Creator | `agents.unbund.com` |
| **OpenClaw** | Classic Game Engine (Claw) | `claw.unbund.com` |
| **n8n** | Self-hosted Automation Tool (Low-code) | `n8n.unbund.com` |
| **Ollama** | Backend LLM Engine | `Internal Service` |

*Note: Replace `unbund.com` with your actual domain in the `/apps` YAML files.*

### 🌐 Local Access

To access the applications from your browser (e.g., `http://chat.unbund.com`), you need to map these domains to your local IP.

**Option 1: Quick Setup (Recommended)**
Run the helper command (requires `sudo` to edit `/etc/hosts`):
```bash
just local-dns
```

**Option 2: Manual Setup**
Add the following line to your `/etc/hosts` file:
```text
127.0.0.1 chat.unbund.com benchmark.unbund.com agents.unbund.com n8n.unbund.com claw.unbund.com grafana.unbund.com
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

To spin up the entire cluster with minimal manual effort, follow these steps:

### 1. Initialize Configuration
First, generate your `.env` file from the template:
```bash
just setup-env
```

### 2. Configure Credentials
Edit the newly created `.env` file and fill in your details:
- **DOMAIN**: Your base domain (unbund.com).
- **CF_TUNNEL_ID**: Your Cloudflare Tunnel ID.
- **CF_API_TOKEN**: Your Cloudflare API Token.
- **AGE_KEY_PATH**: (Optional) Custom path for your Age key.

### 3. Run the Lab
Simply run:
```bash
just run
```

This command will now:
1. **Apply Configs**: Automatically replace placeholders in `infrastructure/values.yaml` and create the Cloudflare secret.
2. **Setup Cluster**: Create the Kind cluster with optimized settings.
3. **Secret Management**: Initialize and inject your Age private key.
4. **Bootstrap**: Install ArgoCD and apply the Root Application.

---
**⚠️ Note:** Data is ephemeral (EmptyDir). Destroying the cluster will wipe all data. Always back up your `~/.age/homelab.txt` file (or the path defined in `AGE_KEY_PATH`)!
