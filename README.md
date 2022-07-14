# ucldc-nuxeo-server

This repo contains the Dockerfile for [building the custom UCLDC nuxeo server image](https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/). This image is built on top of the official Nuxeo docker image and includes the custom package that we built in Nuxeo Studio.

## Build the custom image

### Set env vars needed for docker build

````
cp exportenv.template exportenv.local
````

Populate `exportenv.local` with relevant values, then:

```
source ./exportenv.local
```

### Create ucldc.conf

```
cp ucldc.conf.template ucldc.conf
```

Populate `ucldc.conf` with the relevant values.

### Create instance.clid

```
cp instance.clid.template instance.clid
```

Populate `instance.clid` with the relevant values.

### Build base image

You will first need to login to Nuxeo's private docker registry (providing token name and code when prompted). (To be given access to the private docker registry, you have to file a ticket with Nuxeo). Login command:

```
docker login docker-private.packages.nuxeo.com
```
Set env vars needed by docker build if you haven't already:

```
source ./exportenv.local
```

Build an image tagged `ucldc/nuxeo-base:2021` using `Dockerfile.base`:

```
docker build \
    -f Dockerfile.base \
    -t ucldc/nuxeo-base:2021.21 \
    --build-arg NUXEO_VERSION \
    --build-arg NUXEO_CUSTOM_PACKAGE \
    --build-arg CLID \
    .
```

### Build full image using default Dockerfile

Note: make sure you have built the base image first. `Dockerfile` installs packages such as `amazon-s3-online-storage` on top of the base image created above. The reason for this 2-step build process is that some of these packages will cause errors when developing locally. TODO: figure out a better way to handle this.

Build an image tagged `ucldc/nuxeo:2021` using `Dockerfile` (the default):

```
docker build \
    -t ucldc/nuxeo:2021 \
    --build-arg NUXEO_VERSION \
    --build-arg CLID \
    .
```

### Build full image using alternate Dockerfile (i.e. for local dev)

Build an image tagged `ucldc/nuxeo-localdev:2021` using `Dockerfile.localdev`:

```
docker build \
    -f Dockerfile.localdev \
    -t ucldc/nuxeo-localdev:2021 \
    --build-arg NUXEO_VERSION \
    .
```

## Run the image in a container

Run the image in a container and get a shell prompt. Note: this container will be removed upon exit because of the `rm` flag:

```
docker run --rm -i -t \
    --name ucldc-nuxeo \
    -p 8080:8080 \
    ucldc/nuxeo:2021 \
    /bin/bash
```

From the shell prompt inside the docker container, start nuxeo:

```
nuxeoctl start
```

## Push the image to ECR

https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html
