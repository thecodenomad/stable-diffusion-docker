IGPU="0"
ROCM_VERSION="5.7"
HSA_OVERRIDE_GFX_VERSION="11.0.0"
NIGHTLY="0"

#.PHONY: build_cache 
build_cache:
	mkdir -p mounts/comfyui-output    \
                 mounts/comfyui-web       \
                 mounts/stablediff-models \
                 mounts/stablediff-web    \
                 mounts/stablediff.env    \
                 build_cache


        # Build base container to grab pytorch dependencies 
	podman-compose build --build-arg IGPU="${IGPU}"                                         \
		             --build-arg ROCM_VERSION="${ROCM_VERSION}"                         \
			     --build-arg NIGHTLY="${NIGHTLY}"                                   \
			     --build-arg HSA_OVERRIDE_GFX_VERSION="${HSA_OVERRIDE_GFX_VERSION}" \
	                     base

        # Grab the pytorch files
	podman run -it -v ./build_cache:/tmp/pip_cache:Z stable-diffusion-docker_base:latest /usr/local/bin/pytorch_cache.sh

sd: build_cache 
	podman pod rm -f pod_stable-diffusion-docker

        # Build base container to grab pytorch dependencies 
	#podman-compose build --build-arg IGPU="${IGPU}"                                         \
#		             --build-arg ROCM_VERSION="${ROCM_VERSION}"                         \
#			     --build-arg NIGHTLY="${NIGHTLY}"                                   \
#			     --build-arg HSA_OVERRIDE_GFX_VERSION="${HSA_OVERRIDE_GFX_VERSION}" \
#			     stablediff-rocm-web 
	#podman-compose build stablediff-rocm-web

	# podman-compose build stablediff-rocm-web 
	podman-compose --verbose up stablediff-rocm-web 

comfyui: build_cache 
	podman pod rm -f pod_stable-diffusion-docker 

        # Build base container to grab pytorch dependencies 
	podman-compose build --build-arg IGPU="${IGPU}"                                         \
		             --build-arg ROCM_VERSION="${ROCM_VERSION}"                         \
			     --build-arg NIGHTLY="${NIGHTLY}"                                   \
			     --build-arg HSA_OVERRIDE_GFX_VERSION="${HSA_OVERRIDE_GFX_VERSION}" \
			     stablediff-comfyui 

	# podman-compose build stablediff-comfyui
	podman-compose up stablediff-comfyui 

clean:
	# rm -rf build_cache
	podman pod rm -f pod_stable-diffusion-docker
	podman image rm -f stable-diffusion-docker_stablediff-rocm-web
	podman image rm -f stable-diffusion-docker_stablediff-comfyui
	podman image rm -f stable-diffusion-docker_rocm-base
	podman image rm -f stable-diffusion-docker_base
