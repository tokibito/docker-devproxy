GOVERSION = 1.11
GOLANG_DOCKER_IMAGE = golang:$(GOVERSION)
REPO = github.com/moriyoshi/devproxy
EXECUTABLE_NAME = devproxy
VARIANTS = linux-amd64 linux-arm32v6 linux-arm32v7 linux-arm64v8 linux-ppc64le linux-s390x windows-amd64
EXECUTABLES =$(foreach v,$(VARIANTS),bin/devproxy.$(v) )
DOCKER_REPO_NAME = tokibito/devproxy
DOCKER_TAG = latest

all: create-manifest

create-manifest: push-images
	docker manifest create --amend "$(DOCKER_REPO_NAME):$(DOCKER_TAG)" $(foreach v,$(VARIANTS), $(DOCKER_REPO_NAME).$(v):$(DOCKER_TAG) )
	for DOCKER_ARCH in $(VARIANTS); do \
		docker manifest annotate "$(DOCKER_REPO_NAME):$(DOCKER_TAG)" "$(DOCKER_REPO_NAME).$${DOCKER_ARCH}:$(DOCKER_TAG)" --os "`echo $${DOCKER_ARCH} | cut -f 1 -d '-'`" --arch "`echo $${DOCKER_ARCH} | cut -f 2 -d '-' | sed -E -e 's/^(arm64|arm).*/\\1/'`" --variant "`echo $${DOCKER_ARCH} | cut -f 2 -d '-' | sed -E -n -e '/arm/ { s/^arm(32|64)//; p; }'`"; \
	done
	docker manifest push "$(DOCKER_REPO_NAME):$(DOCKER_TAG)" 

push-images: roll-images
	for DOCKER_ARCH in $(VARIANTS); do \
		docker push "$(DOCKER_REPO_NAME).$${DOCKER_ARCH}:$(DOCKER_TAG)"; \
	done

roll-images: $(EXECUTABLES)
	IFS='|'; while read DOCKER_ARCH GOOS GOARCH GOARM EXE_SUFFIX; do \
		if ! echo "$${DOCKER_ARCH}" | grep -q "^#"; then \
			docker build --build-arg "DOCKER_ARCH=$${DOCKER_ARCH}" --build-arg "EXE_SUFFIX=$${EXE_SUFFIX}" --tag "$(DOCKER_REPO_NAME).$${DOCKER_ARCH}:$(DOCKER_TAG)" .; \
		fi; \
	done < builds.txt

$(EXECUTABLES):
	docker run --rm -v "$${PWD}/bin:/usr/src/app/bin" -w /usr/src/app -e "GOPATH=/usr/src/app" -e "REPO=$(REPO)" -i $(GOLANG_DOCKER_IMAGE) sh -c "\
IFS='|'; while read DOCKER_ARCH GOOS GOARCH GOARM _; do \
	export DOCKER_ARCH GOOS GOARCH GOARM; \
	if ! echo \"\$${DOCKER_ARCH}\" | grep -q \"^#\"; then \
		echo \"BUILDING $(EXECUTABLE_NAME).\$${DOCKER_ARCH}\"; \
		go get -d -v \"\$${REPO}\" && go build -tags netgo -v -o \"bin/$(EXECUTABLE_NAME).\$${DOCKER_ARCH}\" \"\$${REPO}\"; \
	fi; \
done" < builds.txt

pull:
	docker pull $(GOLANG_DOCKER_IMAGE)

.PHONY: all create-manifest push-images roll-images pull
