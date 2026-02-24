# Agent Instructions: Gemini CLI

When interacting with this repository, Gemini must follow these rules:

## 1. Project Context
- **Tooling**: GitOps with ArgoCD, Kind for local Kubernetes, Cloudflare for ingress.
- **Organization**: Use the `apps/` folder for new user-facing applications.
- **Infrastructure**: Use the `infrastructure/` folder for cluster-wide services.
- **Workflow**: Create folders and YAML files inside `apps/`, then ArgoCD will sync them.

## 2. Coding Standards
- **YAML**: Always include a `Namespace`, `Deployment`, `Service`, and `Ingress` if applicable.
- **Namespace**: Use `namespace: apps` for new application manifests.
- **Resource Limits**: Always include `resources: requests` and `limits` to avoid OOM in local clusters.
- **Storage**: Use `PersistentVolumeClaim` (PVC) for any stateful service (DBs, LLM model folders).

## 3. Maintenance
- **Documentation**: Update `docs/ARCHITECTURE.md` or `docs/APPLICATIONS.md` when adding significant features.
- **Structure**: Always check `bootstrap/apps.yaml` to see how applications are being discovered.

## 4. Automation & Agent Creation
- **Automated Agents**: Gemini should prefer creating **CronJobs** or **Jobs** in `apps/agent-cronjobs/` for any task that needs automation.
- **n8n Integration**: Use `n8n` for complex event-driven workflows (accessible at `n8n.yourdomain.com`).
- **Headless Agents**: When the user asks for an "agent" to do a job periodically, write a Kubernetes `CronJob` that uses a Python image and calls the internal `ollama:11434` API.
- **Persistence**: Do not use PVCs unless explicitly requested for small agent tasks; prefer `emptyDir` for speed and simplicity in local environments.

## 5. Interaction Guidelines
- **Language**: Default to English for all internal documentation and commit messages.
- **Verbosity**: Be concise, professional, and explain *why* a change is being made.
- **Commits**: Use the **Conventional Commits** format (e.g., `feat:`, `fix:`, `docs:`, `chore:`).
- **Proactive**: If an application requires a GPU or high resources (like LLMs), ask the user if they have configured `nvidia-container-runtime` or adjusted `kind-config.yaml`.
