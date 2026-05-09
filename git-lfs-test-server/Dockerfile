# syntax=docker.io/docker/dockerfile:1.23

FROM golang:1.26.3-trixie AS builder
WORKDIR /src
RUN curl -L https://github.com/git-lfs/lfs-test-server/archive/d27ad23fddc1949ecd9a4ba6a3d074bc6a567084.tar.gz | tar xz --strip-components=1
RUN CGO_ENABLED=0 go build -ldflags="-s"

FROM debian:trixie-slim
RUN <<EOF
#!/bin/bash
set -euxo pipefail
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    git-lfs \
    htop \
    less \
    man \
    openssl \
    procps \
    vim-tiny \
    wget
rm -rf /var/lib/apt/lists/*
EOF
COPY --chmod=0755 <<-"EOF" /etc/profile.d/login.sh
#!/usr/bin/bash
[[ "$-" != *i* ]] && return
export EDITOR=vim
export PAGER=less
alias l='ls -lF --color'
alias ll='l -a'
alias h='history 25'
alias j='jobs -l'
EOF
COPY --chmod=0644 <<-"EOF" /root/.inputrc
"\e[A": history-search-backward
"\e[B": history-search-forward
"\eOD": backward-word
"\eOC": forward-word
set show-all-if-ambiguous on
set completion-ignore-case on
EOF
RUN <<EOF
git config --global user.name "Root Doe"
git config --global user.email root@test
git config --global push.default simple
EOF
EXPOSE 8080
COPY --from=builder /src/lfs-test-server /usr/local/bin/
ENTRYPOINT ["lfs-test-server"]
