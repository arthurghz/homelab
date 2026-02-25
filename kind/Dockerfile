FROM kindest/node:v1.31.0

# Instala o NVIDIA Container Toolkit com a sintaxe corrigida
RUN apt-get update && apt-get install -y curl gnupg \
    && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
    && apt-get update && apt-get install -y nvidia-container-toolkit \
    && nvidia-ctk runtime configure --runtime=containerd

# O Kind aplicará as configurações de runtime via patches no kind-config.yaml
