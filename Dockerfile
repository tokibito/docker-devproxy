FROM scratch

ARG DOCKER_ARCH
ARG EXE_SUFFIX
WORKDIR /app
ENTRYPOINT ["/bin/devproxy${EXE_SUFFIX}", "devproxy.yml"]

COPY bin/devproxy.${DOCKER_ARCH} /bin/devproxy${EXE_SUFFIX}
ONBUILD COPY . /app
