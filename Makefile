

build:
	docker compose down
	#./build_images.sh
	docker compose build

clean:
	docker compose down
	docker system prune -f
	#./build_images.sh -n
	docker compose build --no-cache

push:
	docker tag cuda-dl-lab mmrl/cuda-dl-lab
	docker image push mmrl/cuda-dl-lab

stop:
	docker compose down

hub:
	docker compose up -d jupyterhub

test:
	docker compose up cuda-test

.PHONY: build clean push stop hub test
