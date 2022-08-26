FROM ubuntu:20.04

ARG TARGETPLATFORM

ENV DEBIAN_FRONTEND="noninteractive"
ENV KUBECTL="1.23.10"
ENV TZ="Europe/Berlin"
ENV YQ="4.27.2"

# Instal packages
RUN apt-get update && apt-get install -y --no-install-recommends \
  tzdata=2022a-0ubuntu0.20.04 \
  ca-certificates=20211016~20.04.1 \
  curl=7.68.0-1ubuntu2.12 \
  dnsutils=1:9.16.1-0ubuntu2.10 \
  iputils-ping=3:20190709-3 \
  jq=1.6-1ubuntu0.20.04.1 \
  git=1:2.25.1-1ubuntu3.5 \
  nmap=7.80+dfsg1-2build1 \
  openssh-client=1:8.2p1-4ubuntu0.5 \
  vim-tiny=2:8.1.2269-1ubuntu5.7 \
  wget=1.20.3-1ubuntu2 \
  && rm -rf /var/lib/apt/lists/*

# Config ca-certificates for wget
RUN echo "ca_certificate=/etc/ssl/certs/ca-certificates.crt" > $HOME/.wgetrc

# Set Timezone
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata

# kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL}/bin/$TARGETPLATFORM/kubectl -o /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl

# yq
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then ARCHITECTURE=arm; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi && \
  wget https://github.com/mikefarah/yq/releases/download/v${YQ}/yq_linux_${ARCHITECTURE} -O /usr/local/bin/yq && \
  chmod +x /usr/local/bin/yq

CMD ["kubectl", "version", "--short"]

