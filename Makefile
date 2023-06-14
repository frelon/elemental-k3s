
DOCKER?=docker
ELEMENTAL?=elemental
REPO?=frallan/elemental-k3s:latest
ISO_REPO?=frallan/elemental-k3s:latest-iso

.PHONY: build
build:
	$(DOCKER) build -t $(ISO_REPO) -f Dockerfile.iso .
	$(DOCKER) build -t $(REPO) .
	$(DOCKER) push $(REPO)
	$(ELEMENTAL) build-iso --config-dir=./ -o build --local $(ISO_REPO)

