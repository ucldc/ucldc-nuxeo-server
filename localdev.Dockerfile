ARG NUXEO_VERSION
FROM ucldc/nuxeo-base:${NUXEO_VERSION}

ARG UCLDC_CONF=./nuxeo-conf/localdev-ucldc.conf
COPY $UCLDC_CONF /etc/nuxeo/conf.d/ucldc.conf

# install additional packages for local dev
ARG CLID
ARG CONNECT_URL=https://connect.nuxeo.com/nuxeo/site/
RUN /install-packages.sh --clid ${CLID} --connect-url ${CONNECT_URL} \
    nuxeo-platform-3d-jsf-ui
