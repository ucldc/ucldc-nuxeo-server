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

## How to renew Nuxeo registration

Nuxeo requires that application instances have a valid `CLID`. In our case, this CLID is stored on the docker container in a file named `/var/lib/nuxeo/instance.clid`. You can see the expiration date of the CLID by logging into Nuxeo and going to `ADMIN --> Nuxeo Online Services —> Nuxeo Online Services Registration Status`.

These are the official Nuxeo instructions for how to renew registration: https://doc.nuxeo.com/nxdoc/registering-your-nuxeo-instance/#renewing-registration-for-your-nuxeo-instance. However, we have found that this process doesn't play nice with our Docker deployment, and that we need to register from scratch instead. See below.

**Steps to register from scratch:**

Generate a new CLID:

1. Login to nuxeo-stg via the GUI at https://nuxeo-stg.cdlib.org as an administrator.
1. Navigate to ADMIN --> Nuxeo Online Services. Click "Unregister" at the bottom of the screen.
1. Follow the prompts to register the instance from scratch. You will need to login to the Nuxeo Online Services Portal (https://connect.nuxeo.com). We currently only have 2 seats for this service. Barbara and Adrian are our users as of this writing (April 2026).

Once this is done, you should see an updated "Expiration date" and a new CLID on the ADMIN --> Nuxeo Online Services screen.

In the `nuxeo-stg` CodeBuild project, change the `NuxeoCliId` environment variable to the new CLID. Then rebuild the Docker image by triggering a run of the build project. This will push the new image to ECR.

Create a new `nuxeo-stg` ECS task definition revision based on the new image that was just pushed to ECR.

Update the `nuxeo-stg-service` ECS service with this new task definition.

Once you've verified that stage looks good, update the `nuxeo-prd` CodeBuild project with the new CLID, create a new `nuxeo-prd` task definition revision, and do a force redeploy of the `nuxeo-prd-service` ECS service.