

build:
	docker-compose down
	docker system prune -f
	./build_images.sh
	docker-compose build

clean: build
	docker-compose up -d

.PHONY: clean
