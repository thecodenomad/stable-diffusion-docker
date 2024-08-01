###################
# Base Rocm Image #
###################
FROM rocm/dev-ubuntu-22.04 as base

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8
RUN apt-get update &&\
    apt-get install -y \
    wget \
    git \
    python3 \
    python3-pip \
    python-is-python3
RUN python -m pip install --upgrade pip wheel 

COPY scripts/pytorch_cache.sh /usr/local/bin/pytorch_cache.sh

WORKDIR /sdtemp

#################
# Torch Install #
#################
FROM base as rocm-base

# Nightly
# ENV TORCH_COMMAND="pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.1"

# Stable 
# TODO: Remove, this was just for iterating to not destroy pypi
RUN mkdir -p /tmp/pip_cache
COPY ./build_cache/* /tmp/pip_cache
RUN pip install /tmp/pip_cache/*

#ENV TORCH_COMMAND="pip install --pre torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.1"

# TODO: Re-enable
# ENV TORCH_COMMAND="pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.1"

#RUN python -m $TORCH_COMMAND

EXPOSE 7860

###########################
# Stable Diffusion Web UI #
###########################
FROM rocm-base as stablediff-webui-runner

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui /sdtemp

RUN python launch.py --skip-torch-cuda-test --exit
RUN python -m pip install opencv-python-headless
WORKDIR /stablediff-web

#############################
# Stable Diffusion Comfy UI #
#############################
FROM rocm-base as comfyui-runner 

RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui_temp
RUN pip install -r /comfyui_temp/requirements.txt

WORKDIR /comfyui
