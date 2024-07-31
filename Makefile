build:
	podman-compose build
	mkdir -p mounts/comfyui-output    \
                 mounts/comfyui-web       \
                 mounts/stablediff-models \
                 mounts/stablediff-web    \
                 mounts/stablediff.env

sd: build
	podman pod rm -f pod_stable-diffusion
	podman-compose up stablediff-rocm-web 

comfyui: build
	podman pod rm -f pod_stable-diffusion
	podman-compose up stablediff-comfyui 
