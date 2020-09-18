FROM 046223933678.dkr.ecr.us-east-1.amazonaws.com/helm:base2.16.11

ARG KUBECTL_SOURCE=kubernetes-release/release
ENV KUBECTL_ARCH="linux/amd64"

RUN apk add --update --upgrade --no-cache ca-certificates jq bash curl git gettext libintl

ARG KUBECTL_TRACK=stable.txt

RUN KUBECTL_VERSION=$(curl -SsL --retry 5 "https://storage.googleapis.com/${KUBECTL_SOURCE}/${KUBECTL_TRACK}") && \
  curl -SsL --retry 5 "https://storage.googleapis.com/${KUBECTL_SOURCE}/${KUBECTL_VERSION}/bin/${KUBECTL_ARCH}/kubectl" > /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl

ADD assets /opt/resource
RUN chmod +x /opt/resource/*

RUN mkdir -p "$(helm home)/plugins"
RUN helm plugin install https://github.com/databus23/helm-diff && \
  helm plugin install https://github.com/rimusz/helm-tiller

RUN apk del curl jq git

ENTRYPOINT [ "/bin/bash" ]
