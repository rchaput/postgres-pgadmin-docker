# Ensure consistent image name
IMAGE_NAME = postgres_pgadmin4
# List of source files for the Docker image. The `build-docker` rule will only trigger if these files change.
DOCKER_SRC = Dockerfile dvdrental.tar pgadmin_config.py pgadmin_servers.json run_pgadmin.sh supervisord.conf
# Default container name when instantiating a container
CONTAINER_NAME = db
# Current Git branch name, with `/` replaced with `-`, for the image tag.
BRANCH_NAME = $(shell git branch --show-current | sed -e 's/\//-/g')
# Short Git commit identifier, to ensure unique image tags. This means that an image will be tagged as both `my-branch` and `my-branch_c6bb15c`
# (and previous images from the same branch are kept as `my-branch_44b2054`)
SHORT_SHA = $(shell git rev-parse --short HEAD)

build-docker: $(DOCKER_SRC)
	docker build --tag $(IMAGE_NAME):$(BRANCH_NAME) --tag $(IMAGE_NAME):$(BRANCH_NAME)_$(SHORT_SHA) .

build-docker-multiplatform: $(DOCKER_SRC)
	docker buildx build --platform linux/amd64,linux/arm64 --tag $(IMAGE_NAME):$(BRANCH_NAME) --tag $(IMAGE_NAME):$(BRANCH_NAME)_$(SHORT_SHA) .

run-docker:
	docker run --name $(CONTAINER_NAME) -p 127.0.0.1:5432:5432 -p 127.0.0.1:5050:5050 -d $(IMAGE_NAME):$(BRANCH_NAME)

populate-docker:
	docker exec -it $(CONTAINER_NAME) /usr/local/bin/pg_restore -d dvdrental --create --username=postgres /root/dvdrental.tar

.PHONY: run-docker populate-docker
