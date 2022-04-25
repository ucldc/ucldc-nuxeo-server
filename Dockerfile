# https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/
ARG NUXEO_VERSION

FROM docker-private.packages.nuxeo.com/nuxeo/nuxeo:${NUXEO_VERSION}

ARG CLID
ARG CONNECT_URL=https://connect.nuxeo.com/nuxeo/site/
ARG NUXEO_CUSTOM_PACKAGE

RUN /install-packages.sh --clid ${CLID} --connect-url ${CONNECT_URL} \
    ${NUXEO_CUSTOM_PACKAGE} \
    amazon-s3-online-storage \
    nuxeo-drive \
    nuxeo-jsf-ui \
    nuxeo-quota \
    nuxeo-virtualnavigation \
    nuxeo-web-ui

RUN rm -rf $NUXEO_HOME/local-packages

COPY ./ucldc.conf /etc/nuxeo/conf.d/ucldc.conf

# become root
USER 0
# install RPM Fusion free repository
RUN yum -y localinstall --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
# install ffmpeg package
RUN yum -y install ffmpeg
# set back original user
USER 900
