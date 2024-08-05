###################
# Base Rocm Image #
###################
FROM rocm/dev-ubuntu-22.04 as base

# Build Args
ARG HSA_OVERRIDE_GFX_VERSION=11.0.0
ARG IGPU=0
ARG NIGHTLY=0 
ARG ROCM_VERSION=5.7

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8

ENV HSA_OVERRIDE_GFX_VERSION $HSA_OVERRIDE_GFX_VERSION
ENV IGPU $IGPU
ENV NIGHTLY $NIGHTLY
ENV ROCM_VERSION $ROCM_VERSION

RUN env

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

RUN mkdir -p /tmp/pip_cache
COPY build_cache/* /tmp/pip_cache

# Install the cached wheels
RUN pip install /tmp/pip_cache/*

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

# Install ComfyUI Manager
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git /comfyui_temp/custom_nodes/ComfyUI-Manager

RUN pip install -r /comfyui_temp/requirements.txt

COPY ./extra_model_paths.yaml /comfyui_temp/extra_model_paths.yaml

WORKDIR /comfyui

