

build:
	docker-compose down
	./build_images.sh
	docker-compose build

clean:
	docker-compose down
	docker system prune -f
	./build_images.sh -n
	docker-compose build

push:
	docker tag cuda-dl-lab mmrl/cuda-dl-lab
	docker image push mmrl/cuda-dl-lab

hub: build
	docker-compose up -d

.PHONY: build clean push hub
