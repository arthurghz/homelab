FROM kindest/node:v1.31.0

# Instala o NVIDIA Container Toolkit
RUN apt-get update && apt-get install -y curl gnupg \
    && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
    && apt-get update && apt-get install -y nvidia-container-toolkit

# Configura o containerd para usar o nvidia-container-runtime
RUN nvidia-ctk runtime configure --runtime=containerd

# CRITICAL PARA WSL2: Configura o caminho das bibliotecas
RUN mkdir -p /etc/nvidia-container-runtime && \
    echo "disable-require = false" > /etc/nvidia-container-runtime/config.toml && \
    echo "ldconfig = \"/sbin/ldconfig\"" >> /etc/nvidia-container-runtime/config.toml

# Garante que o sistema procure bibliotecas no mount do WSL2
RUN echo "/usr/lib/wsl/lib" > /etc/ld.so.conf.d/wsl.conf && ldconfig
