FROM ubuntu:16.04 as builder

# Locales
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y apt-utils locales software-properties-common && locale-gen en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8


# Common packages
RUN apt-get update && apt-get install -y \
      build-essential \
      curl \
      git  \
      iputils-ping \
      jq \
      libncurses5-dev \
      libevent-dev \
      net-tools \
      netcat-openbsd \
      rubygems \
      ruby-dev \
      silversearcher-ag \
      socat \
      tmux \
      tzdata \
      wget \
      ninja-build


# Install tmux
WORKDIR /tmp
RUN wget https://github.com/tmux/tmux/releases/download/2.5/tmux-2.5.tar.gz
RUN tar xzvf tmux-2.5.tar.gz
WORKDIR /tmp/tmux-2.5
RUN ./configure
RUN make
RUN make install

# Install neovim
RUN apt-get install -y \
      autoconf \
      automake \
      cmake \
      g++ \
      libtool \
      libtool-bin \
      pkg-config \
      python3 \
      python3-pip \
      unzip
RUN pip3 install --upgrade pip &&\ 
    pip3 install --user neovim jedi mistune psutil setproctitle
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/neovim/neovim.git
WORKDIR /tmp/neovim
RUN git fetch --depth 1 origin tag v0.2.0
RUN git reset --hard v0.2.0
RUN make CMAKE_BUILD_TYPE=Release
RUN make install


FROM ubuntu:16.04
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=builder /usr/local/ /usr/local/
RUN apt-get update && apt-get install -y apt-utils locales software-properties-common curl && locale-gen en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install docker
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D &&\
      echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list &&\
      apt-get install -y apt-transport-https &&\
      apt-get update &&\
      apt-get install -y docker-engine
RUN  curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.13.0/docker-compose-$(uname -s)-$(uname -m)" &&\
     chmod +x /usr/local/bin/docker-compose

# Install go
RUN add-apt-repository ppa:longsleep/golang-backports
RUN apt-get update
RUN apt-get install -y golang-1.8-go zsh
RUN chsh -s /usr/bin/zsh

RUN apt-get install -y \
      libtool \
      libtool-bin \
      pkg-config \
      python3 \
      python3-pip

# Colors and italics for tmux
COPY xterm-256color-italic.terminfo /root
RUN tic /root/xterm-256color-italic.terminfo
ENV TERM=xterm-256color-italic

RUN pip3 install --upgrade pip &&\
    pip3 install --user neovim jedi mistune psutil setproctitle
