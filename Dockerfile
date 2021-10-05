FROM ubuntu:20.04

ARG TARGETPLATFORM

ENV DEBIAN_FRONTEND="noninteractive"
ENV KUBECTL="1.20.7"
ENV TZ="Europe/Berlin"

# Instal packages
RUN apt-get update && apt-get install -y --no-install-recommends \
  tzdata=2021a-0ubuntu0.20.04 \
  ca-certificates=20210119~20.04.2 \
  curl=7.68.0-1ubuntu2.7 \
  dnsutils=1:9.16.1-0ubuntu2.8 \
  iputils-ping=3:20190709-3 \
  git=1:2.25.1-1ubuntu3.2 \
  openssh-client=1:8.2p1-4ubuntu0.3 \
  vim-tiny=2:8.1.2269-1ubuntu5.3 \
  wget=1.20.3-1ubuntu1 \
  && rm -rf /var/lib/apt/lists/*

# Set Timezone
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata

# kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL}/bin/$TARGETPLATFORM/kubectl -o /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl

CMD ["kubectl", "version", "--short"]

