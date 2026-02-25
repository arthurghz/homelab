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

# SCRIPT DE FIX PARA WSL2: Cria links simbólicos para as libs do Windows no local padrão do Linux
# Isso evita o erro "LIBRARY_NOT_FOUND" pois o NVML procura em /usr/lib/x86_64-linux-gnu
RUN printf '#!/bin/bash\n\
for lib in /usr/lib/wsl/lib/libnvidia-*.so*; do\n\
  ln -sf "$lib" "/usr/lib/x86_64-linux-gnu/$(basename "$lib")"\n\
done\n\
ln -sf /usr/lib/wsl/lib/libcuda.so.1.1 /usr/lib/x86_64-linux-gnu/libcuda.so.1\n\
ln -sf /usr/lib/wsl/lib/libcuda.so.1.1 /usr/lib/x86_64-linux-gnu/libcuda.so\n\
ldconfig\n' > /usr/local/bin/wsl-nvidia-fix.sh && chmod +x /usr/local/bin/wsl-nvidia-fix.sh

# Cria o serviço para rodar o fix no boot do nó
RUN printf "[Unit]\nDescription=Fix NVIDIA libs for WSL2\nAfter=multi-user.target\n\n[Service]\nType=oneshot\nExecStart=/usr/local/bin/wsl-nvidia-fix.sh\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/wsl-nvidia-fix.service && \
    systemctl enable wsl-nvidia-fix.service
