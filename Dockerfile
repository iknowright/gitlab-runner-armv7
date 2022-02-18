FROM golang:1.13.9-alpine3.11 as build

ARG GIT_LFS_VERSION

RUN mkdir -p src/github.com/git-lfs/git-lfs && \
wget -nv -O /tmp/git-lfs.tar.gz https://github.com/git-lfs/git-lfs/archive/v${GIT_LFS_VERSION}.tar.gz && \
tar xf  /tmp/git-lfs.tar.gz  -C src/github.com/git-lfs/git-lfs --strip-components 1 && \
GOARCH=arm GOOS=linux GOARM_VERSION=7 CGO_ENABLED=0 go build -a -ldflags '-extldflags "-static"' -o bin/git-lfs github.com/git-lfs/git-lfs/ 


FROM arm32v7/alpine:3.10

RUN adduser -D -S -h /home/gitlab-runner gitlab-runner

RUN apk add --no-cache \
    bash \
    ca-certificates \
    git \
    openssl \
    tzdata \
    wget

ARG DOCKER_MACHINE_VERSION
ARG TINI_VERSION
ARG GITLAB_RUNNER_VERSION

COPY --from=build /go/bin/git-lfs /usr/bin/git-lfs
RUN wget -nv "https://gitlab-runner-downloads.s3.amazonaws.com/v${GITLAB_RUNNER_VERSION}/binaries/gitlab-runner-linux-arm" -O /usr/bin/gitlab-runner && \
    chmod +x /usr/bin/gitlab-runner && \
    chmod +x /usr/bin/git-lfs && \
    ln -s /usr/bin/gitlab-runner /usr/bin/gitlab-ci-multi-runner && \
    gitlab-runner --version && \
    mkdir -p /etc/gitlab-runner/certs && \
    chmod -R 700 /etc/gitlab-runner && \
    wget -nv "https://github.com/docker/machine/releases/download/v${DOCKER_MACHINE_VERSION}/docker-machine-Linux-armhf" -O /usr/bin/docker-machine && \
    chmod +x /usr/bin/docker-machine && \
    docker-machine --version && \
    wget -nv "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-armhf" -O /usr/bin/tini && \
    chmod +x /usr/bin/tini && \
    tini --version && \
    git-lfs install --skip-repo && \
    git-lfs version

RUN wget -nv "https://gitlab.com/gitlab-org/gitlab-runner/-/raw/v${GITLAB_RUNNER_VERSION}/dockerfiles/alpine/entrypoint" -O /entrypoint && \
    chmod +x /entrypoint

STOPSIGNAL SIGQUIT
VOLUME ["/etc/gitlab-runner", "/home/gitlab-runner"]
ENTRYPOINT ["/usr/bin/tini","--", "/entrypoint"]
CMD ["run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]
