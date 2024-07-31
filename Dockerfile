###################
# Base Rocm Image #
###################
FROM rocm/dev-ubuntu-22.04 as rocm-base
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8
WORKDIR /sdtemp
RUN apt-get update &&\
    apt-get install -y \
    wget \
    git \
    python3 \
    python3-pip \
    python-is-python3
RUN python -m pip install --upgrade pip wheel onnxruntime-gpu

ENV TORCH_COMMAND="pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.1"

RUN python -m $TORCH_COMMAND

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui /sdtemp

# Grab ComfyUI source
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui_temp

EXPOSE 7860

###########################
# Stable Diffusion Web UI #
###########################
FROM rocm-base as stablediff-webui-runner

RUN python launch.py --skip-torch-cuda-test --exit
RUN python -m pip install opencv-python-headless
WORKDIR /stablediff-web

#############################
# Stable Diffusion Comfy UI #
#############################
FROM rocm-base as comfyui-runner 

# For convenience
RUN mkdir -p /stablediff-web/models/Stable-diffusion 

WORKDIR /comfyui_temp

RUN pip install -r requirements.txt

WORKDIR /comfyui
