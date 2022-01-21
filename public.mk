GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
GIT_COMMIT_ID=$(shell git rev-parse HEAD)
GIT_COMMIT_ID_SHORT=$(shell git rev-parse --short HEAD)
GIT_PROJECT_FULL_NAME=$(shell git config --local remote.origin.url | awk -F '/' '{print $$2}' | sed 's/.git//g')

DOCKER_BUILDKIT=1
DOCKERFILE=Dockerfile
DOCKER_BUILD_BASE_DIR=.
DOCKER_HUB=registry.cn-shanghai.aliyuncs.com

IMAGE_NAME_SUFFIX=
IMAGE_TAG_TIMESTAMP=$(shell date +"%y%m%d%H%M%S")
IMAGE_NAME=$(GIT_PROJECT_FULL_NAME)/${CUSTOM_IMAGE_NAME}$(IMAGE_NAME_SUFFIX):$(GIT_BRANCH)_$(GIT_COMMIT_ID_SHORT)_$(IMAGE_TAG_TIMESTAMP)
IMAGE_NAME_LATEST=$(GIT_PROJECT_FULL_NAME)/${CUSTOM_IMAGE_NAME}$(IMAGE_NAME_SUFFIX):$(GIT_BRANCH)_latest

build:
	DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker build \
		--progress=plain \
		-t $(DOCKER_HUB)/$(IMAGE_NAME) \
		-t $(DOCKER_HUB)/$(IMAGE_NAME_LATEST) \
		-f $(DOCKERFILE) \
		$(DOCKER_BUILD_BASE_DIR)
	docker push $(DOCKER_HUB)/$(IMAGE_NAME)
	docker push $(DOCKER_HUB)/$(IMAGE_NAME_LATEST)
