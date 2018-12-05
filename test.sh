#!/bin/sh
set -ex

docker run -d --privileged --rm --name kube --hostname kind kind:kube
docker exec -t kube kube-start
docker exec -ti kube sh
