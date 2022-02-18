# Gitlab Runner for RPi4 armv7

RPi host
```
Client: Docker Engine - Community
 Version:           20.10.5
 API version:       1.41
 Go version:        go1.13.15
 Git commit:        55c4c88
 Built:             Tue Mar  2 20:18:46 2021
 OS/Arch:           linux/arm
 Context:           default
 Experimental:      true

Server: Docker Engine - Community
 Engine:
  Version:          20.10.5
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.13.15
  Git commit:       363e9a8
  Built:            Tue Mar  2 20:16:18 2021
  OS/Arch:          linux/arm
  Experimental:     false
 containerd:
  Version:          1.4.4
  GitCommit:        05f951a3781f4f2c1911b05e61c160e9c30eaa8e
 runc:
  Version:          1.0.0-rc93
  GitCommit:        12644e614e25b05da6fd08a38ffa0cfe1903fdec
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

## Build gitlab-runner armv7 image
1. build
`docker build -t gitlab-runner-armv7 --build-arg GIT_LFS_VERSION=3.0.2 --build-arg GITLAB_RUNNER_VERSION=12.10.1 --build-arg DOCKER_MACHINE_VERSION=0.16.2 --build-arg TINI_VERSION=0.19.0 .`

2. verify
`docker run --rm -it gitlab-runner-armv7 --help`

3. running gitlab-runner service
`docker-compose up -d`

4. register runner
When gitlab-runner service is running, we use `docker exec` command to interact with running container, and using `gitlab-runner registry` with some extra arguments to make the runner working.
Please refer the [link](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#use-the-docker-executor-with-docker-socket-binding) to register the runner.
```
docker exec -it gitlab-runner-armv7 \
  gitlab-runner register -n \
    --url https://gitlab.com/ \
    --registration-token REGISTRATION_TOKEN \
    --executor docker \
    --description "RPi4 Runner armv7" \
    --docker-image "docker" \
    --docker-volumes /var/run/docker.sock:/var/run/docker.sock
```

5. verify runner
`docker exec -it gitlab-runner-armv7 gitlab-runner verify`

Now gitlab-runner is up and runner
