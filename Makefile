build_cache:
	mkdir -p mounts/comfyui-output    \
                 mounts/comfyui-web       \
                 mounts/stablediff-models \
                 mounts/stablediff-web    \
                 mounts/stablediff.env    \
                 build_cache

        # Download pytorch dependencies
	podman-compose --version build base 
	podman run -it -v ./build_cache:/tmp/pip_cache:Z stable-diffusion-docker_base:latest /usr/local/bin/pytorch_cache.sh

sd: build_cache 
	podman pod rm -f pod_stable-diffusion-docker 
	podman-compose build stablediff-rocm-web 
	podman-compose --verbose up stablediff-rocm-web 

comfyui: build_cache 
	podman pod rm -f pod_stable-diffusion-docker 
	podman-compose build stablediff-comfyui
	podman-compose up stablediff-comfyui 

clean:
	# rm -rf build_cache
	podman pod rm -f pod_stable-diffusion-docker
	podman image rm -f stable-diffusion-docker_stablediff-rocm-web
	podman image rm -f stable-diffusion-docker_stablediff-comfyui
	podman image rm -f stable-diffusion-docker_rocm-base
