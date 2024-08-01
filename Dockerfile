###################
# Base Rocm Image #
###################
FROM rocm/dev-ubuntu-22.04 as base

ARG HSA_OVERRIDE_GFX_VERSION
ENV HSA_OVERRIDE_GFX_VERSION=$HSA_OVERRIDE_GFX_VERSION

ARG IGPU
ENV IGPU=$IGPU

ARG ROCM_VERSION 
ENV ROCM_VERSION=$ROCM_VERSION

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8

RUN echo $ROCM_VERSION; echo $HSA_OVERRIDE_GFX_VERSION; echo $IGPU

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
COPY ./build_cache/* /tmp/pip_cache

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
RUN pip install -r /comfyui_temp/requirements.txt

WORKDIR /comfyui
