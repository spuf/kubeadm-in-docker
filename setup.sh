#!/bin/sh
set -ex

docker info

kubeadm version --output short
kubelet --version
kubectl version --short --client

kube-start

kubeadm init \
    --node-name kind \
    --apiserver-advertise-address 0.0.0.0 \
    --skip-token-print \
    --ignore-preflight-errors all

kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl label node kind node-role.kubernetes.io/node=

# workaround for https://github.com/kubernetes/kubernetes/issues/50787 and related 'conntrack' errors, kubeadm config should work but it doesn't for some reason.
kubectl -n kube-system get cm kube-proxy -o yaml | sed 's|maxPerCore: [0-9]*|maxPerCore: 0|g' > kube-proxy-cm.yaml
kubectl -n kube-system delete cm kube-proxy
kubectl -n kube-system create -f kube-proxy-cm.yaml
rm -f kube-proxy-cm.yaml
kubectl delete pod -l k8s-app=kube-proxy -n kube-system

kubectl wait # wait all nodes running

kubectl cluster-info
kubectl describe nodes
kubectl get pods --all-namespaces

supervisord ctl stop kubelet
sleep 10
docker stop $(docker ps -q) | cat
docker container prune -f
supervisord ctl stop dockerd

tar -cf /docker-cache.tar -C /var/lib/docker ./
