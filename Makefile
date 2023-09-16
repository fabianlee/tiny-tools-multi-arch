OWNER := fabianlee
PROJECT := tiny-tools-multi-arch
VERSION := 2.0.0

# OCI image index schema (not supported by older container registry servers)
# https://github.com/opencontainers/image-spec/blob/main/manifest.md
OPV := $(OWNER)/$(PROJECT):$(VERSION)

# Docker v2.2 image list index schema (fat manifest, with broad support)
# https://github.com/distribution/distribution/blob/main/docs/spec/manifest-v2-2.md
OPV22 := $(OWNER)/$(PROJECT)v22:$(VERSION)

# you may need to change to "sudo docker" if not a member of 'docker' group
# to add user to docker group: sudo usermod -aG docker $USER
DOCKERCMD := "docker"

# https://github.com/docker-library/bashbrew/blob/v0.1.2/architecture/oci-platform.go#L14-L27
PLATFORMS_LIST := "linux/amd64,linux/arm64,linux/arm/v7"

# additional linux capabilities
CAPS=
#CAPS= --cap-add SYS_TIME --cap-add SYS_NICE

# local volumes
VOL_FLAG=
#VOL_FLAG= -v $(shell pwd)/chrony.conf:/etc/chrony/chrony.conf:ro

# build time values
BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')
GITREF := $(shell git rev-parse --short HEAD)

## builds multi-arch docker image using OCI image manifest
docker-multi-arch-build-push:
	@echo GITREF is $(GITREF)
	@echo checking for 'docker login' required in this step
	if docker system info | grep -E "Username|Registry" ; then \
	echo "logged into Docker"; \
	else \
	echo "NOT logged into Docker"; false; \
	fi
	$(DOCKERCMD) buildx ls
	# must create because 'default' does not have driver capable of multi-platform
	$(DOCKERCMD) buildx create --name mybuilder --driver docker-container || true
	$(DOCKERCMD) buildx use mybuilder
	$(DOCKERCMD) buildx inspect mybuilder | grep ^Driver
	#
	$(DOCKERCMD) buildx build --platform $(PLATFORMS_LIST) --build-arg "BUILD_TIME=$(BUILD_TIME)" --build-arg "GITREF=$(GITREF)" -f Dockerfile -t $(OPV) --push .
	#
	# creates OCI manifest index schema, mediaType: application/vnd.oci.image.index.v1+json
	$(DOCKERCMD) manifest inspect $(OPV) | head

## converts OCI image manifest to Docker v2.2 manifest
## https://github.com/regclient/regclient/blob/main/docs/regctl.md
docker-multi-arch-push-dockerv22:
	[ -f regctl ] || curl -L https://github.com/regclient/regclient/releases/latest/download/regctl-linux-amd64 >regctl
	chmod 755 regctl
	./regctl image mod $(OPV) --to-docker --create $(OPV22)
	$(DOCKERCMD) manifest inspect $(OPV22) | head

## local builds of specific target platforms
docker-build-run-amd64:
	$(DOCKERCMD) buildx create --name mybuilder --driver docker-container || true
	$(DOCKERCMD) buildx use mybuilder
	$(DOCKERCMD) buildx build --platform linux/amd64 --load -t $(OPV) -f Dockerfile .
	$(DOCKERCMD) image ls | head
	$(DOCKERCMD) run --platform linux/amd64 $(OPV) uname -m
docker-build-run-arm64:
	$(DOCKERCMD) buildx create --name mybuilder --driver docker-container || true
	$(DOCKERCMD) buildx use mybuilder
	$(DOCKERCMD) buildx build --platform linux/arm64 --load -t $(OPV) -f Dockerfile .
	$(DOCKERCMD) image ls | head
	$(DOCKERCMD) run --platform linux/arm64 $(OPV) uname -m
docker-build-run-arm32:
	$(DOCKERCMD) buildx create --name mybuilder --driver docker-container || true
	$(DOCKERCMD) buildx use mybuilder
	$(DOCKERCMD) buildx build --platform linux/arm/v7 --load -t $(OPV) -f Dockerfile .
	$(DOCKERCMD) image ls | head
	$(DOCKERCMD) run --platform linux/arm/v7 $(OPV) uname -m

## cleans docker image
clean:
	$(DOCKERCMD) image rm -f $(OPV) || true

## runs specific versions in foreground
docker-run-fg-amd64: clean
	$(DOCKERCMD) run -it --platform linux/amd64 --network host $(CAPS) $(VOL_FLAG) --rm $(OPV) sh
docker-run-fg-arm64: clean
	$(DOCKERCMD) run -it --platform linux/arm64 --network host $(CAPS) $(VOL_FLAG) --rm $(OPV) sh

## runs container in foreground (native arch)
docker-run-fg: clean
	$(DOCKERCMD) run -it --network host $(CAPS) $(VOL_FLAG) --rm $(OPV) sh

## run container in background (native arch)
docker-run-bg: docker-stop clean
	$(DOCKERCMD) run -d --network host $(CAPS) $(VOL_FLAG) --rm --name $(PROJECT) $(OPV) /bin/sh -c 'cat /build.log; while [ 1 ]; do echo "sleeping for 10..";sleep 10; done'
	$(DOCKERCMD) ps

## attach to console of container running in background
docker-cli-bg:
	$(DOCKERCMD) exec -it $(PROJECT) sh

## stops container running in background
docker-stop:
	$(DOCKERCMD) stop $(PROJECT) || true
	$(DOCKERCMD) ps

## tails logs
docker-logs:
	$(DOCKERCMD) logs $(PROJECT)

