FROM kindest/node:v1.31.0

# 1. Instala o NVIDIA Container Toolkit
RUN apt-get update && apt-get install -y curl gnupg \
    && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
    && apt-get update && apt-get install -y nvidia-container-toolkit

# 2. Configura o toolkit para o ambiente Kind/WSL2
RUN nvidia-ctk runtime configure --runtime=containerd && \
    nvidia-ctk config --set nvidia-container-runtime.modes.cdi.default-kind=management

# 3. Script para rodar no boot e resolver os problemas de biblioteca do WSL2
RUN printf '#!/bin/bash\n\
# Espera o mount do WSL2 estar disponível\n\
while [ ! -f /usr/lib/wsl/lib/libnvidia-ml.so.1 ]; do sleep 1; done\n\
\n\
# Registra as bibliotecas no sistema\n\
echo "/usr/lib/wsl/lib" > /etc/ld.so.conf.d/wsl.conf\n\
ldconfig\n\
\n\
# Cria links simbólicos essenciais que o NVML e o Plugin procuram\n\
ln -sf /usr/lib/wsl/lib/libnvidia-ml.so.1 /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1\n\
ln -sf /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 /usr/lib/x86_64-linux-gnu/libnvidia-ml.so\n\
ln -sf /usr/lib/wsl/lib/libcuda.so.1.1 /usr/lib/x86_64-linux-gnu/libcuda.so.1\n\
ln -sf /usr/lib/x86_64-linux-gnu/libcuda.so.1 /usr/lib/x86_64-linux-gnu/libcuda.so\n\
\n\
# Garante que o nvidia-smi seja encontrado no PATH\n\
ln -sf /usr/lib/wsl/lib/nvidia-smi /usr/local/bin/nvidia-smi\n\
\n\
# Re-configura o ldconfig após os links\n\
ldconfig\n' > /usr/local/bin/wsl-gpu-init.sh && chmod +x /usr/local/bin/wsl-gpu-init.sh

# 4. Cria o serviço systemd para o script de init
RUN printf "[Unit]\nDescription=Initialize GPU for WSL2 in Kind\nAfter=network.target\n\n[Service]\nType=oneshot\nExecStart=/usr/local/bin/wsl-gpu-init.sh\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/wsl-gpu-init.service && \
    systemctl enable wsl-gpu-init.service
