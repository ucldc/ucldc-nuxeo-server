# https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/
ARG NUXEO_VERSION

FROM docker-private.packages.nuxeo.com/nuxeo/nuxeo:${NUXEO_VERSION}

ARG CLID
ARG CONNECT_URL=https://connect.nuxeo.com/nuxeo/site/
ARG NUXEO_CUSTOM_PACKAGE

COPY --chown=900:0 ./${NUXEO_CUSTOM_PACKAGE} $NUXEO_HOME/local-packages/${NUXEO_CUSTOM_PACKAGE}

RUN /install-packages.sh --clid ${CLID} --connect-url ${CONNECT_URL} \
    nuxeo-jsf-ui \
    nuxeo-web-ui \
    $NUXEO_HOME/local-packages/${NUXEO_CUSTOM_PACKAGE}

RUN rm -rf $NUXEO_HOME/local-packages
