CTR_REGISTRY = cybwan
CTR_TAG      = latest

DOCKER_GO_VERSION = 1.17
DOCKER_BUILDX_PLATFORM ?= linux/amd64
DOCKER_BUILDX_OUTPUT ?= type=registry

LDFLAGS ?= "-s -w"

.PHONY: docker-build-time-server
docker-build-time-server:
	docker buildx build --builder osm --platform=$(DOCKER_BUILDX_PLATFORM) -o $(DOCKER_BUILDX_OUTPUT) -t $(CTR_REGISTRY)/mtls-egress-demo-server:$(CTR_TAG) -f dockerfiles/Dockerfile.server --build-arg GO_VERSION=$(DOCKER_GO_VERSION) --build-arg LDFLAGS=$(LDFLAGS) .

.PHONY: docker-build-time-server-without-certs
docker-build-time-server-without-certs:
	docker buildx build --builder osm --platform=$(DOCKER_BUILDX_PLATFORM) -o $(DOCKER_BUILDX_OUTPUT) -t $(CTR_REGISTRY)/mtls-egress-demo-server-without-certs:$(CTR_TAG) -f dockerfiles/Dockerfile.server-without-certs --build-arg GO_VERSION=$(DOCKER_GO_VERSION) --build-arg LDFLAGS=$(LDFLAGS) .

.PHONY: docker-build-time-middle
docker-build-time-middle:
	docker buildx build --builder osm --platform=$(DOCKER_BUILDX_PLATFORM) -o $(DOCKER_BUILDX_OUTPUT) -t $(CTR_REGISTRY)/mtls-egress-demo-middle:$(CTR_TAG) -f dockerfiles/Dockerfile.middle --build-arg GO_VERSION=$(DOCKER_GO_VERSION) --build-arg LDFLAGS=$(LDFLAGS) .

.PHONY: docker-build-time-middle-mtls
docker-build-time-middle-mtls:
	docker buildx build --builder osm --platform=$(DOCKER_BUILDX_PLATFORM) -o $(DOCKER_BUILDX_OUTPUT) -t $(CTR_REGISTRY)/mtls-egress-demo-middle-mtls:$(CTR_TAG) -f dockerfiles/Dockerfile.middle-mtls --build-arg GO_VERSION=$(DOCKER_GO_VERSION) --build-arg LDFLAGS=$(LDFLAGS) .

.PHONY: docker-build-time-client
docker-build-time-client:
	docker buildx build --builder osm --platform=$(DOCKER_BUILDX_PLATFORM) -o $(DOCKER_BUILDX_OUTPUT) -t $(CTR_REGISTRY)/mtls-egress-demo-client:$(CTR_TAG) -f dockerfiles/Dockerfile.client --build-arg GO_VERSION=$(DOCKER_GO_VERSION) --build-arg LDFLAGS=$(LDFLAGS) .

.PHONY: docker-build
docker-build: docker-build-time-server docker-build-time-server-without-certs docker-build-time-middle docker-build-time-middle-mtls docker-build-time-client

.PHONY: docker-build-cross-time-server
docker-build-cross-time-server: DOCKER_BUILDX_PLATFORM=linux/amd64,linux/arm64
docker-build-cross-time-server: docker-build-time-server

.PHONY: docker-build-cross-time-server-without-certs
docker-build-cross-time-server-without-certs: DOCKER_BUILDX_PLATFORM=linux/amd64,linux/arm64
docker-build-cross-time-server-without-certs: docker-build-time-server-without-certs

.PHONY: docker-build-cross-time-middle
docker-build-cross-time-middle: DOCKER_BUILDX_PLATFORM=linux/amd64,linux/arm64
docker-build-cross-time-middle: docker-build-time-middle

.PHONY: docker-build-cross-time-middle-mtls
docker-build-cross-time-middle-mtls: DOCKER_BUILDX_PLATFORM=linux/amd64,linux/arm64
docker-build-cross-time-middle-mtls: docker-build-time-middle-mtls

.PHONY: docker-build-cross-time-client
docker-build-cross-time-client: DOCKER_BUILDX_PLATFORM=linux/amd64,linux/arm64
docker-build-cross-time-client: docker-build-time-client

.PHONY: docker-build-cross
docker-build-cross: docker-build-cross-time-server docker-build-cross-time-server-without-certs docker-build-cross-time-middle docker-build-cross-time-middle-mtls docker-build-cross-time-client

default: docker-build-cross