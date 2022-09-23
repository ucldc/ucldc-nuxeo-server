# ucldc-nuxeo-server

This repo contains the Dockerfile for [building the custom UCLDC nuxeo server image](https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/). This image is built on top of the official Nuxeo docker image and includes the custom package that we built in Nuxeo Studio.

## Build Docker Image and Push to ECR

There is an AWS CodeBuild project for automatically building the Docker image and pushing it to ECR defined as a CloudFormation template here: [https://github.com/cdlib/ucldc-nuxeo-deploy](https://github.com/cdlib/ucldc-nuxeo-deploy) [private repo]

## Build Docker Image Locally

### Create ucldc.conf

For local dev, all you need is an empty `ucldc.conf` file:

```
touch ucldc.conf
```

### Create instance.clid

```
python create_ucldc_conf.py <version> <env>
```
This script fetches the values from AWS Parameter Store and creates an `instance.clid` file.

### Set env vars needed for docker build

````
cp exportenv.template exportenv.local
````

Populate `exportenv.local` with relevant values. Note: you can use the CLID from the `instance.clid` file above. 

Set your environment variables:

```
source ./exportenv.local
```

### Build image

You will first need to login to Nuxeo's private docker registry (providing token name and code when prompted). (To be given access to the private docker registry, you have to file a ticket with Nuxeo). Login command:

```
docker login docker-private.packages.nuxeo.com
```
Set env vars needed by docker build if you haven't already:

```
source ./exportenv.local
```

Build an image tagged `ucldc/nuxeo:2021` using `Dockerfile` (the default):

```
docker build \
    -t ucldc/nuxeo:2021 \
    --build-arg NUXEO_VERSION \
    --build-arg NUXEO_CUSTOM_PACKAGE \
    --build-arg CLID \
    .
```

Note: `Dockerfile` installs packages such as `amazon-s3-online-storage` that will cause errors when installed locally, i.e. without an s3 bucket defined in nuxeo.conf. You may find that you want to comment out some package installs in the Dockerfile.

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

Run the image in a container as daemon with host directories mounted into the container. Nuxeo will start up:

```
docker run -d \
    --name ucldc-nuxeo \
    -p 8080:8080 \   
    -v /path/to/ucldc-nuxeo-server/data:/var/lib/nuxeo \   
    -v /path/to/ucldc-nuxeo-server/log:/var/log/nuxeo \   
    -v /path/to/ucldc-nuxeo-server/tmp:/tmp \ 
    ucldc/nuxeo:2021
```

Nuxeo will start up and logs will be written to `/path/to/ucldc-nuxeo-server/log`.

To stop Nuxeo, run: 

```
docker exec nuxeo nuxeoctl stop
```

See [https://doc.nuxeo.com/nxdoc/quickstart-docker-nuxeo/](https://doc.nuxeo.com/nxdoc/quickstart-docker-nuxeo/) for more info.

Alternatively, for development purposes, here's how to run the image in a container and get a shell prompt. Note: this container will be removed upon exit because of the `rm` flag:

```
docker run --rm -i -t \
    --name ucldc-nuxeo-dev \
    -p 8080:8080 \
    ucldc/nuxeo:2021 \
    /bin/bash
```

From the shell prompt inside the docker container, start nuxeo:

```
nuxeoctl start
```

