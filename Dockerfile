ARG BIRD_VERSION=2.14

FROM debian:12.2-slim AS builder
ARG BIRD_VERSION=2.14
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -q -y install \
  iproute2 \
  tcpdump \
  iputils-ping \
  readline-common \
  libreadline8 \
  libssh-4 \
  inotify-tools \
  curl \
  build-essential \
  flex \
  bison \
  libncurses-dev \
  libreadline-dev \
  libssh-dev \
  git

RUN echo Downloading https://bird.network.cz/download/bird-${BIRD_VERSION}.tar.gz
RUN curl -LOk https://bird.network.cz/download/bird-${BIRD_VERSION}.tar.gz
RUN tar xvf bird-${BIRD_VERSION}.tar.gz
WORKDIR /bird-${BIRD_VERSION}
RUN ./configure
RUN make

FROM debian:12.2-slim
ARG BIRD_VERSION=2.14
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -q -y install \
  iproute2 \
  tcpdump \
  iputils-ping \
  readline-common \
  libreadline8 \
  libssh-4 \
  inotify-tools
RUN mkdir -p /usr/local/var/run
COPY --from=builder /bird-${BIRD_VERSION}/bird /usr/local/sbin/bird
COPY --from=builder /bird-${BIRD_VERSION}/birdc /usr/local/sbin/birdc
COPY birdvars.conf /usr/local/include/birdvars.conf
COPY wrapper.sh /wrapper.sh
COPY reconfig.sh /reconfig.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD ["bird",  "-fR"]
CMD ./wrapper.sh
