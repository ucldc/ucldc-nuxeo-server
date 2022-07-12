# https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/
ARG NUXEO_VERSION
FROM docker-private.packages.nuxeo.com/nuxeo/nuxeo:${NUXEO_VERSION}

ARG CLID
ARG CONNECT_URL=https://connect.nuxeo.com/nuxeo/site/
ARG NUXEO_CUSTOM_PACKAGE

COPY --chown=900:0 ./files/install-hotfixes.sh /install-hotfixes.sh
RUN /install-hotfixes.sh --clid ${CLID} --connect-url ${CONNECT_URL}

RUN /install-packages.sh --clid ${CLID} --connect-url ${CONNECT_URL} \
    ${NUXEO_CUSTOM_PACKAGE} \
    nuxeo-jsf-ui \
    nuxeo-web-ui

# register
COPY ./instance.clid /var/lib/nuxeo/instance.clid

# become root
USER 0

# install ffmpeg
RUN yum -y localinstall --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
RUN yum -y install ffmpeg

# set back original user
USER 900