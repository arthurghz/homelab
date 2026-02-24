# Homelab Applications

## LLM Stack

### Ollama (`apps/ollama/`)
- **Image**: `ollama/ollama:latest`
- **Port**: `11434`
- **Volume**: `50Gi` for models (Llama 3, Mistral, etc.).
- **Purpose**: Local LLM engine.

### Open WebUI (`apps/open-webui/`)
- **Image**: `ghcr.io/open-webui/open-webui:main`
- **Ingress**: `chat.yourdomain.com`
- **Integration**: Pre-configured to talk to `http://ollama:11434`.
- **Purpose**: Main web interface for chat.

### LLM Benchmark (`apps/llm-bench/`)
- **Ingress**: `benchmark.yourdomain.com`
- **Purpose**: Stress test models and hardware (tokens per second, latency).
- **Goal**: Find the best model for your specific machine resources.

### Langflow (`apps/langflow/`)
- **Ingress**: `agents.yourdomain.com`
- **Port**: `7860`
- **Purpose**: Visual tool for creating AI agents, chains, and workflows.

## Other

### OpenClaw (`apps/openclaw/`)
- **Ingress**: `claw.yourdomain.com`
- **Purpose**: Modern game engine reimplementation of the classic game "Claw".
