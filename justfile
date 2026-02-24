# homelab - arthurghz
KIND_CLUSTER := "homelab"
AGE_KEY := "~/.age/homelab.txt"
REPO_URL := "https://github.com/arthurghz/homelab.git"

default:
    @just --list

# 🛠️ INSTALLATION
# Install all required binaries (SRE Toolset)
install-tools:
    @echo "Installing SRE tools..."
    @if ! command -v brew >/dev/null; then 
        /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; 
    fi
    brew install kind kubectl helm sops age just argocd

# 🛠️ SETUP & CLUSTER
cluster-up:
    @echo "Optimizing inotify limits for Kind..."
    sudo sysctl fs.inotify.max_user_watches=524288
    sudo sysctl fs.inotify.max_user_instances=512
    kind create cluster --name {{KIND_CLUSTER}} --config infrastructure/kind-config.yaml

cluster-down:
    kind delete cluster --name {{KIND_CLUSTER}}

# 🔐 SECRET MANAGEMENT
init-sops:
    @if [ ! -f {{AGE_KEY}} ]; then 
        mkdir -p ~/.age && age-keygen -o {{AGE_KEY}}; 
    fi
    @echo "Public Key: $$(grep 'public key' {{AGE_KEY}} | cut -d' ' -f4)"

gen-cf-secret:
    @echo "Creating template: infrastructure/secrets/cloudflare.secret.yaml"
    @mkdir -p infrastructure/secrets
    @printf "apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token
  namespace: networking
type: Opaque
stringData:
  api-token: YOUR_TOKEN_HERE" > infrastructure/secrets/cloudflare.secret.yaml

encrypt path:
    sops --encrypt --in-place {{path}}

inject-age:
    kubectl create namespace sops-system --dry-run=client -o yaml | kubectl apply -f -
    kubectl create secret generic helm-secrets-private-keys 
        --namespace sops-system 
        --from-file=homelab.txt={{AGE_KEY}}

# 🚀 DEPLOYMENT
bootstrap:
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    helm upgrade --install argocd argo/argo-cd --repo https://argoproj.github.io/argo-helm --namespace argocd --wait
    kubectl apply -f bootstrap/root.yaml

# FULL LOCAL RUN: cluster -> age -> argo
run: cluster-up init-sops inject-age bootstrap
