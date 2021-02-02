FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"
ENV KUBECTL="1.20.2"
ENV TZ="Europe/Berlin"

# Instal packages
RUN apt-get update && apt-get install -y --no-install-recommends \
  tzdata=2020d-0ubuntu0.20.04 \
  ca-certificates=20201027ubuntu0.20.04.1 \
  curl=7.68.0-1ubuntu2.2 \
  dnsutils=1:9.16.1-0ubuntu2.4 \
  wget=1.20.3-1ubuntu1 \
  && rm -rf /var/lib/apt/lists/*

# Set Timezone
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata

# kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl


