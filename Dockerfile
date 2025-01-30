# https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/
ARG NUXEO_VERSION=latest
FROM docker-private.packages.nuxeo.com/nuxeo/nuxeo:${NUXEO_VERSION}

ARG CLID
ARG NUXEO_CUSTOM_PACKAGE

# install ffmpeg package
USER 0
RUN dnf -y update
RUN dnf -y --allowerasing install epel-release \
RUN dnf -y config-manager --set-enabled ol9_codeready_builder \
RUN dnf -y config-manager --set-enabled ol9_developer_EPEL \
RUN dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm
RUN dnf -y install ffmpeg
USER 900

# install Nuxeo packages
RUN /install-packages.sh --clid ${CLID} --connect-url https://connect.nuxeo.com/nuxeo/site/ \
    ${NUXEO_CUSTOM_PACKAGE} \
    nuxeo-jsf-ui \
    nuxeo-web-ui \
    amazon-s3-online-storage \
    nuxeo-drive \
    nuxeo-quota \
    nuxeo-quota-jsf-ui \
    nuxeo-virtualnavigation