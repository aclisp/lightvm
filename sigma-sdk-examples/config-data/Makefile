# build the docker image.

REPO=61.160.36.122:8080
PROJECT=default
APP=myapp-config
VERSION=1.0.0

IMAGE=${REPO}/${PROJECT}/${APP}:${VERSION}

all:
	docker build -t ${IMAGE} .
	docker push ${IMAGE}

.PHONY: all
