build:
	podman-compose build

run:
	podman pod rm -f pod_stable-diffusion
	podman-compose up stablediff-rocm 


sd:
	podman pod rm -f pod_stable-diffusion
	podman-compose up stablediff-rocm-web 

comfyui:
	podman pod rm -f pod_stable-diffusion
	podman-compose up stablediff-comfyui 
