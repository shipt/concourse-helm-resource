FROM alpine:3

ARG HELM_VERSION=2.17.0

# ENV BASE_URL="https://storage.googleapis.com/kubernetes-helm"
ENV BASE_URL="https://get.helm.sh"
ENV TAR_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"

RUN apk add --update --upgrade --no-cache ca-certificates jq bash curl git gettext libintl && \
    curl -L ${BASE_URL}/${TAR_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64

WORKDIR /apps

ARG KUBECTL_SOURCE=kubernetes-release/release
ENV KUBECTL_ARCH="linux/amd64"

ARG KUBECTL_TRACK=stable.txt

RUN KUBECTL_VERSION=$(curl -SsL --retry 5 "https://storage.googleapis.com/${KUBECTL_SOURCE}/${KUBECTL_TRACK}") && \
  curl -SsL --retry 5 "https://storage.googleapis.com/${KUBECTL_SOURCE}/${KUBECTL_VERSION}/bin/${KUBECTL_ARCH}/kubectl" > /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl

ADD assets /opt/resource
RUN chmod +x /opt/resource/*

RUN mkdir -p "$(helm home)/plugins"
RUN helm plugin install https://github.com/databus23/helm-diff && \
  helm plugin install https://github.com/rimusz/helm-tiller

RUN apk del curl git && \
    rm -f /var/cache/apk/*

ENTRYPOINT [ "/bin/bash" ]
