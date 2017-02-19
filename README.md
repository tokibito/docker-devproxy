===============
docker-devproxy
===============

devproxy
========

* https://github.com/moriyoshi/devproxy

build
=====

```
$ docker build --rm -t tokibito/devproxy .
```

run
===

```
$ docker run --rm -v $PWD:/app tokibito/devproxy
```

pull
====

```
$ docker pull tokibito/devproxy
```

customize
=========

Dockerfile:

```
FROM tokibito/devproxy
```

The current directory is copied to `/app` directory.

Usage
=====

1. Make devproxy.yml on the current directory.
2. run.
