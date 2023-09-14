OWNER := fabianlee
PROJECT := tiny-tools-multi-arch
VERSION := 1.0.0
OPV := $(OWNER)/$(PROJECT):$(VERSION)

# you may need to change to "sudo docker" if not a member of 'docker' group
# add user to docker group: sudo usermod -aG docker $USER
DOCKERCMD := "docker"

# https://hub.docker.com/_/alpine
#ALPINE_PLATFORMS := "alpine/amd64,alpine/arm64v8"
ALPINE_PLATFORMS := "linux/amd64,linux/arm64/v8"

# additional linux capabilities
CAPS=
#CAPS= --cap-add SYS_TIME --cap-add SYS_NICE

# chrony config file
VOL_FLAG=
#VOL_FLAG= -v $(shell pwd)/chrony.conf:/etc/chrony/chrony.conf:ro

BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')
# unique id from last git commit
MY_GITREF := $(shell git rev-parse --short HEAD)

## builds docker image
docker-build:
	@echo MY_GITREF is $(MY_GITREF)
	$(DOCKERCMD) buildx ls
	## builder might already be created from previous run
	$(DOCKERCMD) buildx create --name mybuilder --driver docker-container --bootstrap --use || true
	## build multi-platform images
	$(DOCKERCMD) buildx build --platform $(ALPINE_PLATFORMS) -f Dockerfile -t $(OPV) --push .
	$(DOCKERCMD) buildx inspect mybuilder
	$(DOCKERCMD) buildx ls
	## by default, creates OCI mediaType: application/vnd.oci.image.index.v1+json
	$(DOCKERCMD) manifest inspect $(OPV)

## cleans docker image
clean:
	$(DOCKERCMD) image rm $(OPV) | true

## runs container in foreground, testing a couple of override values
docker-run-fg: docker-ntp-port-clear
	$(DOCKERCMD) run -it --network host $(CAPS) -p $(EXPOSEDPORT) $(VOL_FLAG) --rm $(OPV)

## runs container in foreground, override entrypoint to use use shell
docker-debug:
	$(DOCKERCMD) run -it --rm --entrypoint "/bin/sh" $(OPV)

## run container in background
## to test multiarch using local qemu
## sudo apt install -y podman buildah qemu-user-static
docker-run-bg: 
	$(DOCKERCMD) run -d --network host $(CAPS) -p $(EXPOSEDPORT) $(VOL_FLAG) --rm --name $(PROJECT) $(OPV)

## get into console of container running in background
docker-cli-bg:
	$(DOCKERCMD) exec -it $(PROJECT) /bin/sh

## tails $(DOCKERCMD)logs
docker-logs:
	$(DOCKERCMD) logs -f $(PROJECT)

## stops container running in background
docker-stop:
	$(DOCKERCMD) stop $(PROJECT)

## pushes to $(DOCKERCMD)hub
docker-push:
	$(DOCKERCMD) push $(OPV)

test:
	./chrony_test.sh

## pushes to kubernetes cluster
k8s-apply:
	sed -e 's/1.0.0/$(VERSION)/' k8s-chrony-alpine.yaml | kubectl apply -f -
	@echo ""
	@echo "Use this debian slim container as a test client: https://github.com/fabianlee/docker-debian-bullseye-slim-ntpclient/blob/main/k8s-debian-slim.yaml"

k8s-delete:
	kubectl delete -f k8s-chrony-alpine.yaml
