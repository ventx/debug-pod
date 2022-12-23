FROM ubuntu:22.04

ARG TARGETPLATFORM

ENV DEBIAN_FRONTEND="noninteractive"
ENV KUBECTL="1.25.5"
ENV TZ="Europe/Berlin"
ENV YQ="4.30.6"

# Instal packages
RUN apt-get update && apt-get install -y --no-install-recommends \
  tzdata=2022g-0ubuntu0.22.04.1 \
  ca-certificates=20211016ubuntu0.22.04.1 \
  curl=7.81.0-1ubuntu1.6 \
  bind9-dnsutils=1:9.18.1-1ubuntu1.2 \
  iputils-ping=3:20211215-1 \
  jq=1.6-2.1ubuntu3 \
  git=1:2.34.1-1ubuntu1.5 \
  nmap=7.91+dfsg1+really7.80+dfsg1-2build1 \
  openssh-client=1:8.9p1-3 \
  tree=2.0.2-1 \
  vim-tiny=2:8.2.3995-1ubuntu2.1 \
  wget=1.21.2-2ubuntu1 \
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

