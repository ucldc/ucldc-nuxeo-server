# https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/
ARG NUXEO_VERSION=latest
FROM docker-private.packages.nuxeo.com/nuxeo/nuxeo:${NUXEO_VERSION}

ARG CLID
ARG NUXEO_CUSTOM_PACKAGE

RUN /install-packages.sh --clid ${CLID} --connect-url https://connect.nuxeo.com/nuxeo/site/ \
    ${NUXEO_CUSTOM_PACKAGE} \
    nuxeo-jsf-ui \
    nuxeo-web-ui \
    amazon-s3-online-storage \
    nuxeo-drive \
    nuxeo-quota \
    nuxeo-quota-jsf-ui \
    nuxeo-virtualnavigation

# install ffmpeg package
USER 0
RUN dnf update \
   && dnf install epel-release \
   && dnf config-manager --set-enabled ol9_codeready_builder \
   && dnf config-manager --set-enabled ol9_developer_EPEL \
   && dnf install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm
RUN dnf install ffmpeg
USER 900