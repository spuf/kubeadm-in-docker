#!/bin/sh
set -ex

docker stop kube || true
docker build -t kind:latest kind

docker run -d --privileged --rm --name kube --hostname kind kind:latest

docker cp ./setup.sh kube:/setup.sh
docker exec kube chmod +x /setup.sh

docker exec -t kube /setup.sh
docker commit kube kind:kube
docker stop kube

echo "Build done!"
