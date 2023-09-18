help:
	@cat Makefile

builder:
	docker buildx use default

build: builder
	docker compose down
	#./build_images.sh
	docker compose build

clean: builder
	docker compose down
	docker system prune -f
	docker buildx prune
	#./build_images.sh -n
	docker compose build --no-cache

push:
	docker tag cuda-dl-lab biocomplab/cuda-dl-lab
	docker image push biocomplab/cuda-dl-lab

stop:
	docker compose down

hub:
	docker compose up -d jupyterhub

test:
	docker compose up cuda-test

.PHONY: build builder clean push stop hub test
