# https://doc.nuxeo.com/nxdoc/build-a-custom-docker-image/
ARG NUXEO_VERSION=latest
FROM docker-private.packages.nuxeo.com/nuxeo/nuxeo:${NUXEO_VERSION}

ARG CLID
ARG NUXEO_CUSTOM_PACKAGE
ENV NUXEO_CUSTOM_PACKAGE=${NUXEO_CUSTOM_PACKAGE}

# install CDL's Nuxeo custom package (if build arg is provided)
RUN if ! [[ -z "$NUXEO_CUSTOM_PACKAGE" ]] ; \
        then \
        /install-packages.sh --clid ${CLID} --connect-url https://connect.nuxeo.com/nuxeo/site/ \
        ${NUXEO_CUSTOM_PACKAGE} ; \
    fi

# install other Nuxeo packages
RUN /install-packages.sh --clid ${CLID} --connect-url https://connect.nuxeo.com/nuxeo/site/ \
    nuxeo-jsf-ui \
    nuxeo-web-ui \
    amazon-s3-online-storage \
    nuxeo-drive \
    nuxeo-quota \
    nuxeo-quota-jsf-ui \
    nuxeo-virtualnavigation

# install ffmpeg
USER 0
RUN dnf -y --allowerasing update \
   && dnf -y install epel-release \
   && dnf -y config-manager --set-enabled ol9_codeready_builder \
   && dnf -y config-manager --set-enabled ol9_developer_EPEL \
   && dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm
RUN dnf -y install ffmpeg
USER 900