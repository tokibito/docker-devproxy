FROM scratch

WORKDIR /app
ENTRYPOINT ["/bin/devproxy", "devproxy.yml"]

COPY bin /bin
ONBUILD COPY . /app
