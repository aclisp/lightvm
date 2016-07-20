# build the docker image.

REPO=61.160.36.122:8080
PROJECT=default
APP=myapp
VERSION=2.0.1

IMAGE=${REPO}/${PROJECT}/${APP}:${VERSION}

all:
	go build myapp.go
	docker build -t ${IMAGE} .
	docker push ${IMAGE}

.PHONY: all
