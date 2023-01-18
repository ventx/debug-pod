FROM ubuntu:22.04

ARG BUILDTIME
ARG REVISION
ARG TARGETPLATFORM
ARG VERSION

LABEL maintainer="Hans Jörg Wieland <hajo@ventx.de>" \
      org.opencontainers.image.authors="Hans Jörg Wieland <hajo@ventx.de>" \
      org.opencontainers.image.base.name="ubuntu:22.04" \
      org.opencontainers.image.created="${BUILDTIME}" \
      org.opencontainers.image.description="Debug Pod for Kubernetes" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.ref.name="ventx/debug-pod" \
      org.opencontainers.image.revision="${REVISION}" \
      org.opencontainers.image.source="https://github.com/ventx/debug-pod" \
      org.opencontainers.image.url="https://github.com/ventx/debug-pod.git" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.vendor="ventx GmbH"

ENV DEBIAN_FRONTEND="noninteractive"
ENV KUBECTL="1.24.9"
ENV TZ="Europe/Berlin"
ENV YQ="4.30.6"
ENV XH="0.17.0"

# Instal packages
RUN apt-get update && apt-get install -y --no-install-recommends \
  tzdata=2022g-0ubuntu0.22.04.1 \
  ca-certificates=20211016ubuntu0.22.04.1 \
  curl=7.81.0-1ubuntu1.7 \
  bind9-dnsutils=1:9.18.1-1ubuntu1.2 \
  iputils-ping=3:20211215-1 \
  jq=1.6-2.1ubuntu3 \
  git=1:2.34.1-1ubuntu1.6 \
  less=590-1build1 \
  mysql-client=8.0.31-0ubuntu0.22.04.1 \
  netcat=1.218-4ubuntu1 \
  nmap=7.91+dfsg1+really7.80+dfsg1-2build1 \
  openssh-client=1:8.9p1-3 \
  postgresql-client=14+238 \
  tree=2.0.2-1 \
  vim-tiny=2:8.2.3995-1ubuntu2.3 \
  wget=1.21.2-2ubuntu1 \
  && rm -rf /var/lib/apt/lists/*


# Config ca-certificates for wget
RUN echo "ca_certificate=/etc/ssl/certs/ca-certificates.crt" > "$HOME/.wgetrc"

# Set Timezone
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata

# kubectl
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCHITECTURE=linux/amd64; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then ARCHITECTURE=linux/arm; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCHITECTURE=linux/arm64; else ARCHITECTURE=linux/amd64; fi && \
  wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL}/bin/${ARCHITECTURE}/kubectl -O /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl

# yq
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then ARCHITECTURE=arm; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi && \
  wget -q https://github.com/mikefarah/yq/releases/download/v${YQ}/yq_linux_${ARCHITECTURE} -O /usr/local/bin/yq && \
  chmod +x /usr/local/bin/yq

# xh
WORKDIR /tmp
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCHITECTURE=x86_64; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then ARCHITECTURE=arm; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCHITECTURE=aarch64; else ARCHITECTURE=x86_64; fi && \
  wget -q "https://github.com/ducaale/xh/releases/download/v${XH}/xh-v${XH}-${ARCHITECTURE}-unknown-linux-$(if [ $ARCHITECTURE = "arm" ]; then echo "gnueabihf"; else echo "musl"; fi).tar.gz" -O /tmp/xh.tar.gz && \
  tar xfz /tmp/xh.tar.gz && mv /tmp/xh-*/xh /usr/local/bin && \
  rm -rf /tmp/xh*

CMD ["kubectl", "version", "--short"]

