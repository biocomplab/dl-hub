

build:
	docker-compose down
	docker system prune -f
	./build_images.sh
	docker-compose build

push:
	docker tag cuda-dl-lab mmrl/cuda-dl-lab
	docker image push mmrl/cuda-dl-lab

clean: build
	docker-compose up -d

.PHONY: clean push
