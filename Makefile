REPO ?= https://github.com/ruifung/bird_router
PROJECT ?= bird_router
REGISTRY ?= ghcr.io/ruifung
BIRD_VERSION ?= 2.14
BUILD_VERSION ?= dev
REGISTRY_IMAGE ?= ${REGISTRY}/${PROJECT}
SUFFIX ?= v${BIRD_VERSION}-${BUILD_VERSION}
TAG ?= ${REGISTRY_IMAGE}:${SUFFIX}
REVISION := $(shell git rev-parse HEAD)

.PHONY: help image install

##@ Default Goal
help: ## Display help message
	@echo "Usage:\n  make [VAR=value ...] <goals>"
	@echo "\nVariables"
	@echo "  REGISTRY       Container registry address"
	@echo "  SUFFIX         Image tag suffix (the part after ':')"
	@echo "  BIRD_VERSION   Version of BIRD to use"
	@awk 'BEGIN {FS = "[:=].*##"}; \
		/^[A-Z]+=.*?##/ { printf "  %-15s %s\n", $$1, $$2 } \
		/^[%a-zA-Z0-9_-]+:.*?##/ { printf "  %-15s %s\n", $$1, $$2 } \
		/^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development Goals
image: ## Build the container image
	docker buildx build -t ${TAG} \
	-t ${REGISTRY_IMAGE}:latest \
	-t ${REGISTRY_IMAGE}:v${BIRD_VERSION} \
	-t ${REGISTRY_IMAGE}:git-${REVISION} \
	-o type=image,oci-mediatypes=true,compression=estargz,force-compression=true,annotation.org.opencontainers.image.source=${REPO},annotation.org.opencontainers.image.revision=$(REVISION) \
	--build-arg BIRD_VERSION=${BIRD_VERSION} \
	--platform linux/amd64,linux/arm64 \
	--cache-from type=registry,ref=${REGISTRY_IMAGE}:v${BIRD_VERSION} \
	--push \
	.