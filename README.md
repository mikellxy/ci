# test-ci

> 提交代码时gitlab runner打包项目生成docker镜像，上传到docker hub。把新上传的docker镜像的tag和镜像生成的时间戳保存到redis，供后续部署使用。

### gitlab ci的.gitlab-ci.yml文件配置

```yml
image: docker:latest
services:
  - docker:dind

stages:
  - test

variables:
  APP_IMAGE_TAG_PROD: $REPO_PREFIX:$CI_COMMIT_SHA  # docker镜像的tag为仓库名:本次commit的hash

test:
  stage: test
  tags:
    - test-ci
  script:
    - docker login -u $REPO_USER -p $REPO_PWD  # 登陆docker hub
    - docker build -t $APP_IMAGE_TAG_LATEST -f $APP_DOCKERFILE .  # 制作go镜像
    - docker tag $APP_IMAGE_TAG_LATEST $APP_IMAGE_TAG_PROD  # 给go镜像打tag
    - docker push $APP_IMAGE_TAG_PROD  # go镜像push到docker hub
    - docker build -t $REDIS_IMAGE_TAG -f $REDIS_DOCKERFILE .  # 制作redis镜像
    - docker run --rm --env APP_NAME=$APP_NAME --env APP_IMAGE_TAG_PROD=$APP_IMAGE_TAG_PROD --env REDIS_HOST=$REDIS_HOST $REDIS_IMAGE_TAG  # 在redis容器里执行脚本把go镜像的tag和时间戳存到redis

```

### gitlab-runner的配置文件
```yml
[[runners]]
  name = "test-ci"
  url = "http://172.17.0.1:8929"
  clone_url = "http://172.17.0.1:8929"  # gitlab和gitlab-runner的host不同是，需指定gitlab的host，否则runner无法拉取代码
  token = "9cS1WY1sUEdQ3Zib_75n"
  executor = "docker"
  environment = ["DOCKER_TLS_CERTDIR="]
  [runners.custom_build_dir]
  [runners.docker]
    tls_verify = false  # 未false时登陆docker hub不需要tls鉴权
    image = "alpine:latest"
    privileged = true  # runner本身运行在容器中，在容器中创建新的docker镜像或者运行新的容器，需要开启这个权限
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"]  # runner会缓存制作docker镜像时的中间layer，可以加速镜像的制作
    shm_size = 0
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
```
