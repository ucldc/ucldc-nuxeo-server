# ucldc-nuxeo-server

This repo contains a Dockerfile for [building the custom UCLDC nuxeo server image](https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/). This image is built on top of the official Nuxeo docker image and includes the custom package that we built in Nuxeo Studio. The code in `client_config/` is run when the application container is started up. This configures Nuxeo for a particular client, i.e. stage or prod.

The repo also contains a Dockerfile for building an nginx image that is configured as a reverse proxy for Nuxeo. This is intended to be run as a "sidecar" container to the application container.

There is an AWS CodeBuild project for building the Docker images and pushing them to ECR, defined as a CloudFormation template here: [https://github.com/cdlib/pad-infrastructure](https://github.com/cdlib/pad-infrastructure) [private repo]

## Local development

First copy `exportenv.template` to `exportenv.local`. Populate the env var values and source the file. These are referenced in `compose-dev.yaml` as build args.

Then, modify nginx.conf. Replace this line:

```
proxy_pass http://localhost:8080;
```

with this line:

```
proxy_pass http://nuxeo:8080;
```

Then, to build the images locally: 

```
docker compose -f compose-dev.yaml build
```

And to run the containers locally:

```
docker compose -f compose-dev.yaml up
```

Nuxeo should now be up at http://localhost

Note that it is assumed that the AWS hosted RDS, OpenSearch and MSK instances are not accessible locally, since they are locked down in a VPC. Therefore, `NUXEO_SKIP_CONFIG` is set to `true` in `compose-dev.yaml`, meaning that the nuxeo client configuration will be skipped. Nuxeo will use the default embedded datastores instead.