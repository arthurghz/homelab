# homelab - arthurghz
set dotenv-load := true

KIND_CLUSTER := "homelab"
AGE_KEY := env_var_or_default("AGE_KEY_PATH", home_dir() + "/.age/homelab.txt")
REPO_URL := "https://github.com/arthurghz/homelab.git"

default:
    @just --list

# 🛠️ INSTALLATION
install-tools:
    @echo "Installing SRE tools..."
    @if ! command -v brew >/dev/null; then \
        /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
    fi
    brew install kind kubectl helm sops age just argocd

# 🛠️ SETUP & CONFIGURATION
setup-env:
    @if [ ! -f .env ]; then \
        cp .env.example .env; \
        echo ".env created from .env.example. Please edit it with your credentials."; \
    else \
        echo ".env already exists."; \
    fi

apply-configs:
    @echo "Applying configurations from .env..."
    @sed -i "s|unbund.com|{{env_var("DOMAIN")}}|g" kind/values.yaml
    @sed -i "s|YOUR_TUNNEL_ID|{{env_var("CF_TUNNEL_ID")}}|g" kind/values.yaml
    @if [ ! -f infrastructure/secrets/cloudflare.secret.yaml ] || grep -q "YOUR_TOKEN_HERE" infrastructure/secrets/cloudflare.secret.yaml; then \
        just gen-cf-secret; \
        sed -i "s|YOUR_TUNNEL_TOKEN|{{env_var("CF_API_TOKEN")}}|g" infrastructure/secrets/cloudflare.secret.yaml; \
        sed -i "s|YOUR_DNS_TOKEN|{{env_var("CF_DNS_API_TOKEN")}}|g" infrastructure/secrets/cloudflare.secret.yaml; \
        just encrypt infrastructure/secrets/cloudflare.secret.yaml; \
    fi
    @echo "Updating Repo URLs in bootstrap..."
    @find bootstrap -name "*.yaml" -exec sed -i "s|https://github.com/arthurghz/homelab.git|{{env_var("GIT_REPO_URL")}}|g" {} +
    @echo "Configurations applied successfully."

apply-secrets:
    @echo "Deploying encrypted secrets to cluster..."
    @kubectl create namespace cloudflare --dry-run=client -o yaml | kubectl apply -f -
    @export SOPS_AGE_KEY_FILE={{AGE_KEY}} && sops --decrypt infrastructure/secrets/cloudflare.secret.yaml | kubectl apply -f -

setup-git-auth:
    @if [ "{{env_var("GIT_SSH_KEY_PATH")}}" != "NONE" ]; then \
        echo "Creating ArgoCD repository secret using SSH key..."; \
        kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -; \
        kubectl create secret generic repo-auth \
            --namespace argocd \
            --from-literal=url={{env_var("GIT_REPO_URL")}} \
            --from-file=sshPrivateKey={{env_var("GIT_SSH_KEY_PATH")}} \
            --dry-run=client -o yaml | kubectl apply -f -; \
        kubectl label secret repo-auth -n argocd "argocd.argoproj.io/secret-type=repository" --overwrite; \
    elif [ "{{env_var("GIT_TOKEN")}}" != "YOUR_GITHUB_TOKEN" ]; then \
        echo "Creating ArgoCD repository secret using Token..."; \
        kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -; \
        kubectl create secret generic repo-auth \
            --namespace argocd \
            --from-literal=url={{env_var("GIT_REPO_URL")}} \
            --from-literal=username={{env_var("GIT_USER")}} \
            --from-literal=password={{env_var("GIT_TOKEN")}} \
            --dry-run=client -o yaml | kubectl apply -f -; \
        kubectl label secret repo-auth -n argocd "argocd.argoproj.io/secret-type=repository" --overwrite; \
    fi

# 🛠️ SETUP & CLUSTER
cluster-up:
    @echo "Optimizing inotify limits for Kind..."
    @echo 2016 | sudo -S sysctl fs.inotify.max_user_watches=524288
    @echo 2016 | sudo -S sysctl fs.inotify.max_user_instances=512
    @kind get clusters | grep -q {{KIND_CLUSTER}} || kind create cluster --name {{KIND_CLUSTER}} --config kind/kind-config.yaml

cluster-down:
    kind delete cluster --name {{KIND_CLUSTER}}

# 🔐 SECRET MANAGEMENT
init-sops:
    @if [ ! -f {{AGE_KEY}} ]; then \
        mkdir -p "{{AGE_KEY}}/.." && age-keygen -o {{AGE_KEY}}; \
    fi
    @echo "Public Key: $$(grep 'public key' {{AGE_KEY}} | cut -d' ' -f4)"

gen-cf-secret:
    @echo "Creating template: infrastructure/secrets/cloudflare.secret.yaml"
    @mkdir -p infrastructure/secrets
    @echo "apiVersion: v1" > infrastructure/secrets/cloudflare.secret.yaml
    @echo "kind: Secret" >> infrastructure/secrets/cloudflare.secret.yaml
    @echo "metadata:" >> infrastructure/secrets/cloudflare.secret.yaml
    @echo "  name: cloudflare-api-key" >> infrastructure/secrets/cloudflare.secret.yaml
    @echo "  namespace: cloudflare" >> infrastructure/secrets/cloudflare.secret.yaml
    @echo "type: Opaque" >> infrastructure/secrets/cloudflare.secret.yaml
    @echo "stringData:" >> infrastructure/secrets/cloudflare.secret.yaml
    @echo "  apiKey: YOUR_DNS_TOKEN" >> infrastructure/secrets/cloudflare.secret.yaml
    @echo "  token: YOUR_TUNNEL_TOKEN" >> infrastructure/secrets/cloudflare.secret.yaml

encrypt path:
    sops --encrypt --in-place {{path}}

inject-age:
    kubectl create namespace sops-system --dry-run=client -o yaml | kubectl apply -f -
    kubectl delete secret generic helm-secrets-private-keys --namespace sops-system --ignore-not-found
    kubectl create secret generic helm-secrets-private-keys \
        --namespace sops-system \
        --from-file=homelab.txt={{AGE_KEY}}

# 🌐 LOCAL DOMAIN MAPPING
local-dns:
    @echo "Updating /etc/hosts for homelab domains..."
    @if ! grep -q "homelab-domains" /etc/hosts; then \
        echo "\n# [homelab-domains] START" | sudo tee -a /etc/hosts; \
        echo "127.0.0.1 chat.{{env_var("DOMAIN")}} benchmark.{{env_var("DOMAIN")}} agents.{{env_var("DOMAIN")}} n8n.{{env_var("DOMAIN")}} claw.{{env_var("DOMAIN")}} grafana.{{env_var("DOMAIN")}} homer.{{env_var("DOMAIN")}} argocd.{{env_var("DOMAIN")}}" | sudo tee -a /etc/hosts; \
        echo "# [homelab-domains] END" | sudo tee -a /etc/hosts; \
    else \
        sudo sed -i '/# \[homelab-domains\] START/,/# \[homelab-domains\] END/c\# [homelab-domains] START\n127.0.0.1 chat.{{env_var("DOMAIN")}} benchmark.{{env_var("DOMAIN")}} agents.{{env_var("DOMAIN")}} n8n.{{env_var("DOMAIN")}} claw.{{env_var("DOMAIN")}} grafana.{{env_var("DOMAIN")}} homer.{{env_var("DOMAIN")}} argocd.{{env_var("DOMAIN")}}\n# [homelab-domains] END' /etc/hosts; \
    fi
    @echo "Domains updated! You can now access services on {{env_var("DOMAIN")}}"

git-sync:
    @echo "Syncing changes to git..."
    @git add .
    @if git diff --cached --quiet; then \
        echo "No changes to commit."; \
    else \
        git commit -m "chore: auto-sync configurations and secrets"; \
        git push origin main || echo "Please push manually if branch differs"; \
    fi

# 🚀 DEPLOYMENT
bootstrap:
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    helm upgrade --install argocd argo-cd --repo https://argoproj.github.io/argo-helm --namespace argocd --wait \
        --set server.extraArgs={--insecure} \
        --set server.rbacConfig."policy.default"=role:admin
    kubectl apply -f bootstrap/root.yaml

# FULL LOCAL RUN
run: setup-env init-sops apply-configs cluster-up inject-age apply-secrets setup-git-auth local-dns git-sync bootstrap
