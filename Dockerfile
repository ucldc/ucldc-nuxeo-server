ARG NUXEO_VERSION
FROM ucldc/nuxeo-base:${NUXEO_VERSION}

ARG UCLDC_CONF=./ucldc.conf
COPY $UCLDC_CONF /etc/nuxeo/conf.d/ucldc.conf

# install packages
ARG CLID
ARG CONNECT_URL=https://connect.nuxeo.com/nuxeo/site/
RUN /install-packages.sh --clid ${CLID} --connect-url ${CONNECT_URL} \
    amazon-s3-online-storage \
    nuxeo-drive \
    nuxeo-quota \
    nuxeo-virtualnavigation

# become root
USER 0

# set back original user
USER 900

