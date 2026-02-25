FROM kindest/node:v1.31.0

# Instala o NVIDIA Container Toolkit
RUN apt-get update && apt-get install -y curl gnupg \
    && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
    && apt-get update && apt-get install -y nvidia-container-toolkit

# Configura o toolkit para usar o runc interno do Kind
RUN nvidia-ctk runtime configure --runtime=containerd

# No WSL2, precisamos garantir que as libs sejam encontradas e que o toolkit saiba onde está o config
RUN mkdir -p /etc/nvidia-container-runtime && \
    nvidia-ctk config --set nvidia-container-runtime.modes.cdi.default-kind=management --output /etc/nvidia-container-runtime/config.toml

RUN echo "/usr/lib/wsl/lib" > /etc/ld.so.conf.d/wsl.conf
