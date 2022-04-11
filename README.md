# ucldc-nuxeo-server

This repo contains the Dockerfile for [building the custom UCLDC nuxeo server image](https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/). This image is built on top of the official Nuxeo docker image and includes the custom package that we built in Nuxeo Studio.

## Build the custom image

### Set env vars needed for docker build

`$ cp exportenv.template exportenv.local`

Populate `exportenv.local` with relevant values, then:

`$ source ./exportenv.local`

### Build the image

Run the following, substituting `<version>` with the version number (this is the docker tag):

`$ docker build -t ucldc/nuxeo:<version> --build-arg NUXEO_VERSION --build-arg NUXEO_CUSTOM_PACKAGE --build-arg CLID .`


## Run the custom image in a container

Run the image in a container and get a shell prompt. Note: this container will be removed upon exit because of the `rm` flag:

`$ docker run --rm -i -t --name ucldc-nuxeo -p 8080:8080 ucldc/nuxeo:2021 /bin/bash`

From the shell prompt inside the docker container, start nuxeo:

`$ nuxeoctl start`
