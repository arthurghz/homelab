FROM kindest/node:v1.31.0

# Instala o NVIDIA Container Toolkit dentro da imagem do nó
RUN apt-get update && apt-get install -y curl gnupg \
    && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
    && apt-get update && apt-get install -y nvidia-container-toolkit

# No WSL2/Kind, o nvidia-container-runtime precisa saber onde está o runc interno
# Configuramos o toolkit para usar o runtime do sistema (containerd/runc)
RUN nvidia-ctk runtime configure --runtime=containerd

# Adiciona o caminho das libs do WSL2 para o carregador do sistema
RUN echo "/usr/lib/wsl/lib" > /etc/ld.so.conf.d/wsl.conf && ldconfig
