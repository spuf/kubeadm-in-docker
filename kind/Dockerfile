FROM docker:18.06-dind

RUN apk add --no-cache curl

# https://kubernetes.io/docs/setup/independent/install-kubeadm/#k8s-install-2
ARG release=v1.12.3
RUN curl -fsSL -o /usr/local/bin/kubeadm "https://storage.googleapis.com/kubernetes-release/release/${release}/bin/linux/amd64/kubeadm" && \
    chmod +x /usr/local/bin/kubeadm
RUN curl -fsSL -o /usr/local/bin/kubelet "https://storage.googleapis.com/kubernetes-release/release/${release}/bin/linux/amd64/kubelet" && \
    chmod +x /usr/local/bin/kubelet
RUN curl -fsSL -o /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/${release}/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

# https://github.com/sgerrand/alpine-pkg-glibc
RUN curl -fsSL -o /etc/apk/keys/sgerrand.rsa.pub "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" && \
    curl -fsSL -o /tmp/glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk" && \
    apk add /tmp/glibc.apk && \
    rm -f /tmp/glibc.apk

# https://github.com/ochinchina/supervisord
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord
COPY supervisor.conf /etc/supervisor.conf

RUN apk add --no-cache tini

COPY kubelet.shim /usr/local/bin/kubelet.shim
RUN chmod +x /usr/local/bin/kubelet.shim

COPY kube-start /usr/local/bin/kube-start
RUN chmod +x /usr/local/bin/kube-start

COPY dockerd.shim /usr/local/bin/dockerd.shim
RUN chmod +x /usr/local/bin/dockerd.shim

ENV KUBECONFIG=/etc/kubernetes/admin.conf

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisor.conf"]
